import 'dart:async';
import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leapdriver/features/driver/constants/driver_constants.dart';
import 'package:leapdriver/core/services/supabase_service.dart';

/// LiveTrackingService
///
/// Time-only mode — posts X6 GPS ping every N minutes.
///
/// Lifecycle:
///   start()  → trip transitions to IN_PROGRESS and liveEnabled = true
///   stop()   → trip COMPLETED
///   pause()  → automatically on X3/X1 (arrived at stop)
///   resume() → automatically on AF (departed stop)

class LiveTrackingService {
  LiveTrackingService._();
  static final LiveTrackingService instance = LiveTrackingService._();

  // ─── State ─────────────────────────────────────────────────────────────────
  bool _running = false;
  bool _paused  = false;

  String? _shipmentXid;
  Timer?  _timer;

  // Retry queue — failed X6 posts are retried on the next successful ping
  final List<Map<String, dynamic>> _retryQueue = [];

  // ─── Settings ──────────────────────────────────────────────────────────────
  int _intervalMinutes = DriverConstants.liveTrackingDefaultIntervalMinutes;

  // ─── Public API ────────────────────────────────────────────────────────────

  bool get isRunning => _running && !_paused;
  bool get isPaused  => _paused;

  Future<void> start({
    required String shipmentXid,
    required String domain,
  }) async {
    if (_running) await stop();

    _shipmentXid = shipmentXid;
    _paused      = false;

    await _loadSettings();

    final hasPermission = await _ensureLocationPermission();
    if (!hasPermission) {
      log('[LiveTracking] ❌ No location permission — aborting');
      return;
    }

    _running = true;
    log('[LiveTracking] ▶ Started · every $_intervalMinutes min');
    await _startTimer();
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _running = false;
    _paused  = false;
    _retryQueue.clear();
    log('[LiveTracking] ⏹ Stopped');
  }

  void pause() {
    _paused = true;
    _timer?.cancel();
    _timer = null;
    log('[LiveTracking] ⏸ Paused');
  }

  Future<void> resume() async {
    _paused = false;
    log('[LiveTracking] ▶ Resumed');
    await _postNow();         // immediate ping on resume
    await _startTimer();      // restart periodic timer
  }

  Future<void> updateSettings({required int intervalMinutes}) async {
    _intervalMinutes = intervalMinutes;
    if (_running && !_paused) {
      _timer?.cancel();
      await _startTimer();
      log('[LiveTracking] ⚙ Interval updated · every $_intervalMinutes min');
    }
  }

  // ─── Timer ─────────────────────────────────────────────────────────────────

  Future<void> _startTimer() async {
    await _postNow(); // immediate ping on start/resume
    _timer = Timer.periodic(
      Duration(minutes: _intervalMinutes),
      (_) => _postNow(),
    );
  }

  // ─── Core post ─────────────────────────────────────────────────────────────

  Future<void> _postNow() async {
    if (!_running || _paused) return;

    await _flushRetryQueue();

    try {
      log('[LiveTracking] Getting position...');
      final position = await _getCurrentPosition();
      if (position == null) {
        log('[LiveTracking] ⚠ Position null — skipping');
        return;
      }
      log('[LiveTracking] Got position: ${position.latitude}, ${position.longitude}');
      await _postX6(position);
    } catch (e) {
      log('[LiveTracking] Error: $e');
    }
  }

  Future<void> _postX6(Position position) async {
    final now    = DateTime.now();
    final offset = now.timeZoneOffset;
    final sign   = offset.isNegative ? '-' : '+';
    final tz     = '$sign${offset.inHours.abs().toString().padLeft(2, '0')}:'
                   '${offset.inMinutes.remainder(60).abs().toString().padLeft(2, '0')}';
    final iso    = '${now.toIso8601String().split('.')[0]}$tz';

    final payload = {
      'statusCodeGid':       'X6',
      'timeZoneGid':         _ianaTimeZone(offset),
      'eventdate':           {'value': iso},
      'responsiblePartyGid': 'CARRIER',
      'stops': {
        'items': [
          {
            'latitude':  position.latitude.toString(),
            'longitude': position.longitude.toString(),
          }
        ]
      },
    };

    try {
      log('[LiveTracking] Posting X6');
      await SupabaseService.postEvent(_shipmentXid!, payload);
      log('[LiveTracking] ✅ X6 posted · '
          '${position.latitude.toStringAsFixed(5)}, '
          '${position.longitude.toStringAsFixed(5)}');
    } catch (e) {
      log('[LiveTracking] ❌ Failed — queued for retry: $e');
      _retryQueue.add(payload);
    }
  }

  Future<void> _flushRetryQueue() async {
    if (_retryQueue.isEmpty) return;
    final toRetry = List<Map<String, dynamic>>.from(_retryQueue);
    _retryQueue.clear();
    for (final payload in toRetry) {
      try {
        await SupabaseService.postEvent(_shipmentXid!, payload);
        log('[LiveTracking] ✅ Retry success');
      } catch (_) {
        _retryQueue.add(payload);
      }
    }
  }

  // ─── Location helpers ──────────────────────────────────────────────────────

  Future<Position?> _getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('GPS timeout'),
      );
    } catch (e) {
      log('[LiveTracking] Could not get position: $e — trying last known');
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          log('[LiveTracking] Using last known: ${last.latitude}, ${last.longitude}');
          return last;
        }
      } catch (_) {}
      return null;
    }
  }

  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    log('[LiveTracking] Location service enabled: $serviceEnabled');
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    log('[LiveTracking] Permission: $permission');

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      log('[LiveTracking] After request: $permission');
    }

    if (permission == LocationPermission.deniedForever) {
      log('[LiveTracking] Permission permanently denied');
      return false;
    }

    return permission == LocationPermission.always ||
           permission == LocationPermission.whileInUse;
  }

  // ─── Persistence ───────────────────────────────────────────────────────────

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _intervalMinutes = prefs.getInt(DriverConstants.prefLiveIntervalMinutes)
        ?? DriverConstants.liveTrackingDefaultIntervalMinutes;
    log('[LiveTracking] Settings: interval=${_intervalMinutes}min');
  }

  static Future<void> saveSettings({
    required bool enabled,
    required int intervalMinutes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(DriverConstants.prefLiveEnabled,        enabled);
    await prefs.setInt(DriverConstants.prefLiveIntervalMinutes, intervalMinutes);
  }

  static Future<bool> loadEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(DriverConstants.prefLiveEnabled)
        ?? DriverConstants.liveTrackingDefaultEnabled;
  }

  // ─── Timezone helper ───────────────────────────────────────────────────────
  // Validates the OS timezone name against OTM's accepted list.
  // If the OS name is valid (e.g. "Asia/Calcutta", "IST") use it directly.
  // Otherwise fall back to offset-based Etc/GMT±N which OTM also accepts.
  static String _ianaTimeZone(Duration offset) {
    final osName = DateTime.now().timeZoneName;
    if (_otmTimezones.contains(osName)) return osName;

    // OS name not in OTM list — use Etc/GMT offset format
    // Note: Etc/GMT sign is INVERTED vs UTC offset convention
    // e.g. UTC+05:30 → Etc/GMT-5 (closest whole hour)
    final hours = offset.inHours;
    if (hours == 0) return 'Etc/GMT';
    // Etc/GMT+N = west of UTC (negative offset), Etc/GMT-N = east of UTC
    final etcSign = hours > 0 ? '-' : '+';
    return 'Etc/GMT$etcSign${hours.abs()}';
  }

  // Complete list of timezone GIDs accepted by OTM (584 entries)
  static const Set<String> _otmTimezones = {
    'ACT','AET','AGT','AKDT','AKST','ART','AST',
    'Africa/Abidjan','Africa/Accra','Africa/Addis_Ababa','Africa/Algiers',
    'Africa/Asmera','Africa/Bamako','Africa/Bangui','Africa/Banjul',
    'Africa/Bissau','Africa/Blantyre','Africa/Brazzaville','Africa/Bujumbura',
    'Africa/Cairo','Africa/Casablanca','Africa/Ceuta','Africa/Conakry',
    'Africa/Dakar','Africa/Dar_es_Salaam','Africa/Djibouti','Africa/Douala',
    'Africa/El_Aaiun','Africa/Freetown','Africa/Gaborone','Africa/Harare',
    'Africa/Johannesburg','Africa/Juba','Africa/Kampala','Africa/Khartoum',
    'Africa/Kigali','Africa/Kinshasa','Africa/Lagos','Africa/Libreville',
    'Africa/Lome','Africa/Luanda','Africa/Lubumbashi','Africa/Lusaka',
    'Africa/Malabo','Africa/Maputo','Africa/Maseru','Africa/Mbabane',
    'Africa/Mogadishu','Africa/Monrovia','Africa/Nairobi','Africa/Ndjamena',
    'Africa/Niamey','Africa/Nouakchott','Africa/Ouagadougou','Africa/Porto-Novo',
    'Africa/Sao_Tome','Africa/Timbuktu','Africa/Tripoli','Africa/Tunis',
    'Africa/Windhoek',
    'America/Adak','America/Anchorage','America/Anguilla','America/Antigua',
    'America/Araguaina','America/Aruba','America/Asuncion','America/Atka',
    'America/Barbados','America/Belem','America/Belize','America/Boa_Vista',
    'America/Bogota','America/Boise','America/Buenos_Aires',
    'America/Cambridge_Bay','America/Cancun','America/Caracas',
    'America/Catamarca','America/Cayenne','America/Cayman','America/Chicago',
    'America/Chihuahua','America/Cordoba','America/Costa_Rica','America/Cuiaba',
    'America/Curacao','America/Danmarkshavn','America/Dawson',
    'America/Dawson_Creek','America/Denver','America/Detroit','America/Dominica',
    'America/Edmonton','America/Eirunepe','America/El_Salvador',
    'America/Ensenada','America/Fort_Wayne','America/Fortaleza',
    'America/Glace_Bay','America/Godthab','America/Goose_Bay',
    'America/Grand_Turk','America/Grenada','America/Guadeloupe',
    'America/Guatemala','America/Guayaquil','America/Guyana','America/Halifax',
    'America/Havana','America/Hermosillo','America/Indiana/Indianapolis',
    'America/Indiana/Knox','America/Indiana/Marengo','America/Indiana/Vevay',
    'America/Indianapolis','America/Inuvik','America/Iqaluit','America/Jamaica',
    'America/Jujuy','America/Juneau','America/Kentucky/Louisville',
    'America/Kentucky/Monticello','America/Knox_IN','America/La_Paz',
    'America/Lima','America/Los_Angeles','America/Louisville',
    'America/Lower_Princes','America/Maceio','America/Managua','America/Manaus',
    'America/Marigot','America/Martinique','America/Mazatlan','America/Mendoza',
    'America/Menominee','America/Merida','America/Mexico_City','America/Miquelon',
    'America/Monterrey','America/Montevideo','America/Montreal',
    'America/Montserrat','America/Nassau','America/New_York','America/Nipigon',
    'America/Nome','America/Noronha','America/North_Dakota/Center',
    'America/Panama','America/Pangnirtung','America/Paramaribo','America/Phoenix',
    'America/Port-au-Prince','America/Port_of_Spain','America/Porto_Acre',
    'America/Porto_Velho','America/Puerto_Rico','America/Rainy_River',
    'America/Rankin_Inlet','America/Recife','America/Regina','America/Rio_Branco',
    'America/Rosario','America/Santiago','America/Santo_Domingo',
    'America/Sao_Paulo','America/Scoresbysund','America/Shiprock',
    'America/St_Barthelemy','America/St_Johns','America/St_Kitts',
    'America/St_Lucia','America/St_Thomas','America/St_Vincent',
    'America/Swift_Current','America/Tegucigalpa','America/Thule',
    'America/Thunder_Bay','America/Tijuana','America/Tortola','America/Vancouver',
    'America/Virgin','America/Whitehorse','America/Winnipeg','America/Yakutat',
    'America/Yellowknife',
    'Antarctica/Casey','Antarctica/Davis','Antarctica/DumontDUrville',
    'Antarctica/Mawson','Antarctica/McMurdo','Antarctica/Palmer',
    'Antarctica/Rothera','Antarctica/South_Pole','Antarctica/Syowa',
    'Antarctica/Vostok',
    'Arctic/Longyearbyen',
    'Asia/Aden','Asia/Alma-Ata','Asia/Almaty','Asia/Amman','Asia/Anadyr',
    'Asia/Aqtau','Asia/Aqtobe','Asia/Ashgabat','Asia/Ashkhabad','Asia/Baghdad',
    'Asia/Bahrain','Asia/Baku','Asia/Bangkok','Asia/Beirut','Asia/Bishkek',
    'Asia/Brunei','Asia/Calcutta','Asia/Choibalsan','Asia/Chongqing',
    'Asia/Chungking','Asia/Colombo','Asia/Dacca','Asia/Damascus','Asia/Dhaka',
    'Asia/Dili','Asia/Dubai','Asia/Dushanbe','Asia/East_Timor','Asia/Gaza',
    'Asia/Harbin','Asia/Hong_Kong','Asia/Hovd','Asia/Irkutsk','Asia/Ishigaki',
    'Asia/Istanbul','Asia/Jakarta','Asia/Jayapura','Asia/Jerusalem','Asia/Kabul',
    'Asia/Kamchatka','Asia/Karachi','Asia/Kashgar','Asia/Katmandu',
    'Asia/Krasnoyarsk','Asia/Kuala_Lumpur','Asia/Kuching','Asia/Kuwait',
    'Asia/Macao','Asia/Macau','Asia/Magadan','Asia/Makassar','Asia/Manila',
    'Asia/Muscat','Asia/Nicosia','Asia/Novosibirsk','Asia/Omsk','Asia/Oral',
    'Asia/Phnom_Penh','Asia/Pontianak','Asia/Pyongyang','Asia/Qatar',
    'Asia/Qyzylorda','Asia/Rangoon','Asia/Riyadh','Asia/Riyadh87',
    'Asia/Riyadh88','Asia/Riyadh89','Asia/Saigon','Asia/Sakhalin',
    'Asia/Samarkand','Asia/Seoul','Asia/Shanghai','Asia/Singapore','Asia/Taipei',
    'Asia/Tashkent','Asia/Tbilisi','Asia/Tehran','Asia/Tel_Aviv','Asia/Thimbu',
    'Asia/Thimphu','Asia/Tokyo','Asia/Ujung_Pandang','Asia/Ulaanbaatar',
    'Asia/Ulan_Bator','Asia/Urumqi','Asia/Vientiane','Asia/Vladivostok',
    'Asia/Yakutsk','Asia/Yekaterinburg','Asia/Yerevan',
    'Atlantic/Azores','Atlantic/Bermuda','Atlantic/Canary','Atlantic/Cape_Verde',
    'Atlantic/Faeroe','Atlantic/Jan_Mayen','Atlantic/Madeira',
    'Atlantic/Reykjavik','Atlantic/South_Georgia','Atlantic/St_Helena',
    'Atlantic/Stanley',
    'Australia/ACT','Australia/Adelaide','Australia/Brisbane',
    'Australia/Broken_Hill','Australia/Canberra','Australia/Darwin',
    'Australia/Hobart','Australia/LHI','Australia/Lindeman','Australia/Lord_Howe',
    'Australia/Melbourne','Australia/NSW','Australia/North','Australia/Perth',
    'Australia/Queensland','Australia/South','Australia/Sydney',
    'Australia/Tasmania','Australia/Victoria','Australia/West',
    'Australia/Yancowinna',
    'BET','BST','Brazil/Acre','Brazil/DeNoronha','Brazil/East','Brazil/West',
    'CAT','CEST','CET','CNT','CST','CST6CDT','CT','CTT',
    'Canada/Atlantic','Canada/Central','Canada/East-Saskatchewan',
    'Canada/Eastern','Canada/Mountain','Canada/Newfoundland','Canada/Pacific',
    'Canada/Saskatchewan','Canada/Yukon',
    'Chile/Continental','Chile/EasterIsland','Cuba',
    'EAT','ECT','EEST','EET','EST','EST5EDT','ET',
    'Egypt','Eire',
    'Etc/GMT','Etc/GMT+0','Etc/GMT+1','Etc/GMT+10','Etc/GMT+11','Etc/GMT+12',
    'Etc/GMT+2','Etc/GMT+3','Etc/GMT+4','Etc/GMT+5','Etc/GMT+6','Etc/GMT+7',
    'Etc/GMT+8','Etc/GMT+9','Etc/GMT-0','Etc/GMT-1','Etc/GMT-10','Etc/GMT-11',
    'Etc/GMT-12','Etc/GMT-13','Etc/GMT-14','Etc/GMT-2','Etc/GMT-3','Etc/GMT-4',
    'Etc/GMT-5','Etc/GMT-6','Etc/GMT-7','Etc/GMT-8','Etc/GMT-9',
    'Etc/GMT0','Etc/Greenwich','Etc/UCT','Etc/UTC','Etc/Universal','Etc/Zulu',
    'Europe/Amsterdam','Europe/Andorra','Europe/Athens','Europe/Belfast',
    'Europe/Belgrade','Europe/Berlin','Europe/Bratislava','Europe/Brussels',
    'Europe/Bucharest','Europe/Budapest','Europe/Chisinau','Europe/Copenhagen',
    'Europe/Dublin','Europe/Gibraltar','Europe/Guernsey','Europe/Helsinki',
    'Europe/Isle_of_Man','Europe/Istanbul','Europe/Jersey','Europe/Kaliningrad',
    'Europe/Kiev','Europe/Lisbon','Europe/Ljubljana','Europe/London',
    'Europe/Luxembourg','Europe/Madrid','Europe/Malta','Europe/Mariehamn',
    'Europe/Minsk','Europe/Monaco','Europe/Moscow','Europe/Nicosia','Europe/Oslo',
    'Europe/Paris','Europe/Podgorica','Europe/Prague','Europe/Riga','Europe/Rome',
    'Europe/Samara','Europe/San_Marino','Europe/Sarajevo','Europe/Simferopol',
    'Europe/Skopje','Europe/Sofia','Europe/Stockholm','Europe/Tallinn',
    'Europe/Tirane','Europe/Tiraspol','Europe/Uzhgorod','Europe/Vaduz',
    'Europe/Vatican','Europe/Vienna','Europe/Vilnius','Europe/Warsaw',
    'Europe/Zagreb','Europe/Zaporozhye','Europe/Zurich',
    'GB','GB-Eire','GMT','GMT0','Greenwich',
    'HST','Hongkong','IET','IST','Iceland',
    'Indian/Antananarivo','Indian/Chagos','Indian/Christmas','Indian/Cocos',
    'Indian/Comoro','Indian/Kerguelen','Indian/Mahe','Indian/Maldives',
    'Indian/Mauritius','Indian/Mayotte','Indian/Reunion',
    'Iran','Israel','JST','Jamaica','Japan','Kwajalein','Libya','Local',
    'MET','MIT','MSD','MSK','MST','MST7MDT','MT',
    'Mexico/BajaNorte','Mexico/BajaSur','Mexico/General',
    'Mideast/Riyadh87','Mideast/Riyadh88','Mideast/Riyadh89',
    'NET','NST','NZ','NZ-CHAT','Navajo',
    'PLT','PNT','PRC','PRT','PST','PST8PDT','PT',
    'Pacific/Apia','Pacific/Auckland','Pacific/Chatham','Pacific/Easter',
    'Pacific/Efate','Pacific/Enderbury','Pacific/Fakaofo','Pacific/Fiji',
    'Pacific/Funafuti','Pacific/Galapagos','Pacific/Gambier',
    'Pacific/Guadalcanal','Pacific/Guam','Pacific/Honolulu','Pacific/Johnston',
    'Pacific/Kiritimati','Pacific/Kosrae','Pacific/Kwajalein','Pacific/Majuro',
    'Pacific/Marquesas','Pacific/Midway','Pacific/Nauru','Pacific/Niue',
    'Pacific/Norfolk','Pacific/Noumea','Pacific/Pago_Pago','Pacific/Palau',
    'Pacific/Palestinian_Territory','Pacific/Pitcairn','Pacific/Ponape',
    'Pacific/Port_Moresby','Pacific/Rarotonga','Pacific/Saipan','Pacific/Samoa',
    'Pacific/Tahiti','Pacific/Tarawa','Pacific/Tongatapu','Pacific/Truk',
    'Pacific/Wake','Pacific/Wallis','Pacific/Yap',
    'Pertopavlovsk-Kamchatskiy','Poland','Portugal',
    'ROK','SST','Singapore',
    'SystemV/AST4','SystemV/AST4ADT','SystemV/CST6','SystemV/CST6CDT',
    'SystemV/EST5','SystemV/EST5EDT','SystemV/HST10','SystemV/MST7',
    'SystemV/MST7MDT','SystemV/PST8','SystemV/PST8PDT','SystemV/YST9',
    'SystemV/YST9YDT',
    'Turkey','UCT',
    'US/Alaska','US/Aleutian','US/Arizona','US/Central','US/East-Indiana',
    'US/Eastern','US/Hawaii','US/Indiana-Starke','US/Michigan','US/Mountain',
    'US/Pacific','US/Pacific-New','US/Samoa',
    'UTC','Universal','VST','W-SU','WET','WST','Zulu',
  };
}