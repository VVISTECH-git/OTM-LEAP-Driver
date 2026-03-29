// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Leap Driver';

  @override
  String get checkSms => 'अपना SMS जांचें';

  @override
  String get smsInstruction =>
      'अपनी यात्रा खोलने के लिए फोन पर भेजे गए शिपमेंट लिंक पर टैप करें।';

  @override
  String get openSmsApp => 'SMS ऐप खोलें';

  @override
  String get smsTapInstruction =>
      'शुरू करने के लिए डिस्पैचर द्वारा भेजे गए शिपमेंट लिंक पर टैप करें।';

  @override
  String get noLoginRequired =>
      'लॉगिन आवश्यक नहीं · SMS लिंक के माध्यम से पहुंच';

  @override
  String get loadingShipment => 'शिपमेंट लोड हो रहा है...';

  @override
  String get unableToLoad => 'लोड करने में असमर्थ';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get noData => 'कोई डेटा नहीं';

  @override
  String get shipment => 'शिपमेंट';

  @override
  String get notStarted => 'शुरू नहीं हुआ';

  @override
  String get headingToPickup => 'पिकअप की ओर जा रहे हैं';

  @override
  String get inTransit => 'पारगमन में';

  @override
  String get allStopsDone => 'सभी स्टॉप पूर्ण · पूरा करने के लिए तैयार';

  @override
  String get tripCompleted => 'यात्रा पूर्ण';

  @override
  String stopProgress(int done, int total) {
    return 'स्टॉप $done में से $total';
  }

  @override
  String stopsNotStarted(int total) {
    return '$total स्टॉप · शुरू नहीं हुआ';
  }

  @override
  String get pendingAcceptance => 'स्वीकृति की प्रतीक्षा';

  @override
  String get accepted => 'स्वीकृत';

  @override
  String get enRoutePickup => 'पिकअप के रास्ते में';

  @override
  String get atPickup => 'पिकअप पर';

  @override
  String get atDelivery => 'डिलीवरी पर';

  @override
  String get delivered => 'डिलीवर किया';

  @override
  String get completed => 'पूर्ण';

  @override
  String get declined => 'अस्वीकृत';

  @override
  String get acceptLoad => '✓  लोड स्वीकार करें';

  @override
  String get startTrip => '▶  यात्रा शुरू करें';

  @override
  String get arrivedAtPickup => '📍  पिकअप पर पहुंचे';

  @override
  String get loaded => '✅  लोड हो गया';

  @override
  String get arrivedAtDelivery => '📍  डिलीवरी पर पहुंचे';

  @override
  String get deliveredBtn => '✅  डिलीवर किया';

  @override
  String get completeTrip => '🏁  यात्रा पूर्ण करें';

  @override
  String get uploadPodToComplete => '🔒  पूरा करने के लिए POD अपलोड करें';

  @override
  String get declineLoad => 'लोड अस्वीकार करें';

  @override
  String get callPickup => 'कॉल\nपिकअप';

  @override
  String get navigate => 'नेविगेट';

  @override
  String get pod => 'POD';

  @override
  String get uploadPod => 'POD अपलोड';

  @override
  String get callDelivery => 'कॉल\nडिलीवरी';

  @override
  String get issue => 'समस्या';

  @override
  String get loadInformation => 'लोड जानकारी';

  @override
  String get routeSection => '📍  रूट';

  @override
  String get loadDetailsSection => '📦  लोड विवरण';

  @override
  String get origin => 'मूल';

  @override
  String get destination => 'गंतव्य';

  @override
  String get pickup => 'पिकअप';

  @override
  String get delivery => 'डिलीवरी';

  @override
  String get stops => 'स्टॉप';

  @override
  String get distance => 'दूरी';

  @override
  String get equipment => 'उपकरण';

  @override
  String get weight => 'वजन';

  @override
  String get hazardous => 'खतरनाक';

  @override
  String get tempControl => 'तापमान नियंत्रण';

  @override
  String get yes => '⚠️  हाँ';

  @override
  String get no => '✓  नहीं';

  @override
  String get yesTemp => '❄️  हाँ';

  @override
  String get stopTimeline => 'स्टॉप';

  @override
  String get allDone => 'सभी पूर्ण ✓';

  @override
  String get done => 'पूर्ण';

  @override
  String get headingHere => '🚛 यहाँ आ रहे हैं';

  @override
  String get youAreHere => '📍 आप यहाँ हैं';

  @override
  String get upNext => '⏳ अगला';

  @override
  String get upcoming => '⏳ आगामी';

  @override
  String get recordedEvents => 'दर्ज घटनाएं';

  @override
  String get arrivedAtStop => 'स्टॉप पर पहुंचे';

  @override
  String get leftStop => 'स्टॉप से निकले';

  @override
  String get podSubmitted => 'POD जमा किया';

  @override
  String get podReminderBanner =>
      '⚠️  POD आवश्यक — यात्रा पूर्ण करने से पहले अपलोड करें';

  @override
  String get reportIssue => 'समस्या रिपोर्ट करें';

  @override
  String get dispatcherNotified => 'आपका डिस्पैचर तुरंत सूचित किया जाएगा।';

  @override
  String get delay => 'देरी';

  @override
  String get breakdown => 'खराबी';

  @override
  String get damage => 'नुकसान';

  @override
  String get dispatcherNotifiedMsg => 'डिस्पैचर को सूचित किया गया';

  @override
  String get locationSharing => 'स्थान साझाकरण';

  @override
  String get shareMyLocation => 'मेरा स्थान साझा करें';

  @override
  String get updatesAutomatically => 'ड्राइव करते समय स्वतः अपडेट होता है।';

  @override
  String get yourDispatcherSees =>
      'आपका डिस्पैचर यात्रा के दौरान आपका स्थान देखता है।';

  @override
  String get locationSharingOn => 'स्थान साझाकरण चालू';

  @override
  String get locationSharingOff => 'स्थान साझाकरण बंद';

  @override
  String get save => 'सहेजें';

  @override
  String get sharingLocation => 'स्थान साझा हो रहा है';

  @override
  String get locationPaused => 'स्थान रुका हुआ';

  @override
  String get locationOn => 'स्थान चालू';

  @override
  String get locationOff => 'स्थान बंद';

  @override
  String get pauseTracking => 'ट्रैकिंग रोकें?';

  @override
  String get pauseTrackingMsg => 'स्थान पिंग तुरंत बंद हो जाएंगे';

  @override
  String get pauseWarning =>
      'डिस्पैचर अब आपकी लाइव स्थिति नहीं देखेगा। फिर से शुरू करने के लिए बैज पर टैप करें।';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get pauseTrackingBtn => 'ट्रैकिंग रोकें';

  @override
  String get confirmAction => 'कार्य की पुष्टि करें';

  @override
  String get youAreAboutTo => 'आप करने वाले हैं:';

  @override
  String get cannotBeUndone => 'इसे पूर्ववत नहीं किया जा सकता।';

  @override
  String get yesConfirm => 'हाँ, पुष्टि करें';

  @override
  String get reasonForDeclining => 'अस्वीकृति का कारण';

  @override
  String get selectReasonBelow => 'नीचे कारण चुनें';

  @override
  String get vehicleIssue => 'वाहन समस्या';

  @override
  String get personalEmergency => 'व्यक्तिगत आपातकाल';

  @override
  String get routeTooLong => 'रूट बहुत लंबा';

  @override
  String get lowRate => 'कम दर';

  @override
  String get other => 'अन्य';

  @override
  String get selectReasonFirst => 'पहले एक कारण चुनें।';

  @override
  String get confirmDecline => 'अस्वीकृति की पुष्टि करें';

  @override
  String get documents => 'दस्तावेज़';

  @override
  String uploadedCount(int count) {
    return '$count / 4 अपलोड';
  }

  @override
  String get podSigned => 'POD (हस्ताक्षरित)';

  @override
  String get podMandatory => 'यात्रा पूर्ण करने से पहले अनिवार्य';

  @override
  String get eWayBill => 'ई-वे बिल';

  @override
  String get invoiceCopy => 'चालान की प्रति';

  @override
  String get damagePhoto => 'नुकसान की फोटो';

  @override
  String get optional => 'वैकल्पिक';

  @override
  String get required => 'आवश्यक';

  @override
  String get uploaded => '✓ अपलोड किया';

  @override
  String get podUploadedMsg => 'POD अपलोड ✓ — अब आप यात्रा पूर्ण कर सकते हैं';

  @override
  String get uploadPodFirst => 'कृपया पहले अपना POD अपलोड करें';

  @override
  String get callPickupContact => 'पिकअप संपर्क';

  @override
  String get callDeliveryContact => 'डिलीवरी संपर्क';

  @override
  String get callNow => 'अभी कॉल करें';

  @override
  String get callingMsg => 'कॉल कर रहे हैं';

  @override
  String get callingDispatcher => 'डिस्पैचर को कॉल कर रहे हैं...';

  @override
  String get tripCompletedTitle => 'यात्रा पूर्ण!';

  @override
  String get tripCompletedSubtitle => 'शिपमेंट सफलतापूर्वक डिलीवर किया गया।';

  @override
  String get callDispatcher => 'डिस्पैचर को कॉल करें';

  @override
  String get podSubmittedBadge => 'POD जमा किया';

  @override
  String get tripClosedBadge => 'यात्रा बंद';

  @override
  String get loadDeclined => 'लोड अस्वीकृत';

  @override
  String get youHaveDeclined => 'आपने यह लोड अस्वीकार कर दिया है।';

  @override
  String get declinedMistake => 'अगर यह गलती थी, तो अपने डिस्पैचर को कॉल करें।';

  @override
  String get couldNotUpdate => 'स्थिति अपडेट नहीं हो सकी। पुनः प्रयास करें।';

  @override
  String get openingMaps => 'मैप्स खोल रहे हैं';

  @override
  String get failedMsg => 'विफल';
}
