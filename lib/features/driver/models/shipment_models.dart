library;


/// Shipment Models
///
/// Centralized model definitions for the driver module.
/// Used by DriverShipmentDetailScreen and AddEventScreen.

// ─── Weight Info ──────────────────────────────────────────────────────────────

class WeightInfo {
  final double value;
  final String unit;

  WeightInfo({required this.value, required this.unit});

  factory WeightInfo.fromJson(Map<String, dynamic> json) {
    return WeightInfo(
      value: (json['value'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
    );
  }
}

// ─── Location Detail ──────────────────────────────────────────────────────────

class LocationDetail {
  final String locationXid;
  final String locationName;
  final String city;
  final String provinceCode;
  final String postalCode;
  final String countryCode3Gid;
  final double? lat;
  final double? lon;

  LocationDetail({
    required this.locationXid,
    required this.locationName,
    required this.city,
    required this.provinceCode,
    required this.postalCode,
    required this.countryCode3Gid,
    this.lat,
    this.lon,
  });

  factory LocationDetail.fromJson(Map<String, dynamic> json) {
    return LocationDetail(
      locationXid: json['locationXid'] ?? '',
      locationName: json['locationName'] ?? '',
      city: json['city'] ?? '',
      provinceCode: json['provinceCode'] ?? '',
      postalCode: json['postalCode'] ?? '',
      countryCode3Gid: json['countryCode3Gid'] ?? '',
      lat: json['lat']?.toDouble(),
      lon: json['lon']?.toDouble(),
    );
  }
}

// ─── Shipment Status ──────────────────────────────────────────────────────────

class ShipmentStatus {
  final String statusTypeGid;
  final String statusValueGid;

  ShipmentStatus({
    required this.statusTypeGid,
    required this.statusValueGid,
  });

  factory ShipmentStatus.fromJson(Map<String, dynamic> json) {
    return ShipmentStatus(
      statusTypeGid: json['statusTypeGid'] ?? '',
      statusValueGid: json['statusValueGid'] ?? '',
    );
  }
}

// ─── Shipment Stop ────────────────────────────────────────────────────────────

/// Stop type values from OTM API:
/// "P"  = Pickup only
/// "D"  = Drop/Delivery only
/// "PD" = Pick + Drop
enum StopType { pickup, drop, pickAndDrop, unknown }

class ShipmentStop {
  final int stopNum;
  final String locationName;
  final String locationXid;
  final String city;
  final String provinceCode;
  final String countryCode;
  final double? lat;
  final double? lon;
  final StopType stopType;
  final String? plannedArrival;
  final String? plannedDeparture;
  final String? estimatedArrival;
  final String? estimatedDeparture;

  ShipmentStop({
    required this.stopNum,
    required this.locationName,
    required this.locationXid,
    required this.city,
    required this.provinceCode,
    required this.countryCode,
    this.lat,
    this.lon,
    required this.stopType,
    this.plannedArrival,
    this.plannedDeparture,
    this.estimatedArrival,
    this.estimatedDeparture,
  });

  factory ShipmentStop.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? {};

    StopType type;
    switch (json['stopType']) {
      case 'P':
        type = StopType.pickup;
        break;
      case 'D':
        type = StopType.drop;
        break;
      case 'PD':
        type = StopType.pickAndDrop;
        break;
      default:
        type = StopType.unknown;
    }

    return ShipmentStop(
      stopNum: json['stopNum'] ?? 0,
      locationName: location['locationName'] ?? '',
      locationXid: location['locationXid'] ?? '',
      city: location['city'] ?? '',
      provinceCode: location['provinceCode'] ?? '',
      countryCode: location['countryCode3Gid'] ?? '',
      lat: location['lat']?.toDouble(),
      lon: location['lon']?.toDouble(),
      stopType: type,
      plannedArrival: json['plannedArrival']?['value'],
      plannedDeparture: json['plannedDeparture']?['value'],
      estimatedArrival: json['estimatedArrival']?['value'],
      estimatedDeparture: json['estimatedDeparture']?['value'],
    );
  }

  /// Display name used in dropdowns and labels
  String get displayName => '$locationName : $stopNum';

  /// Whether this stop requires a POD (signature)
  bool get requiresPod =>
      stopType == StopType.drop || stopType == StopType.pickAndDrop;

  /// Human-readable stop type label
  String get stopTypeLabel {
    switch (stopType) {
      case StopType.pickup:
        return 'Pick-Up';
      case StopType.drop:
        return 'Drop';
      case StopType.pickAndDrop:
        return 'Pick+Drop';
      case StopType.unknown:
        return '';
    }
  }
}

// ─── Tracking Event ───────────────────────────────────────────────────────────

class TrackingEvent {
  final int transactionNo;
  final String statusCodeGid;
  final int shipmentStopNum;
  final String eventLocationGid;
  final String eventDate;
  final String reportingMethod;

  TrackingEvent({
    required this.transactionNo,
    required this.statusCodeGid,
    required this.shipmentStopNum,
    required this.eventLocationGid,
    required this.eventDate,
    required this.reportingMethod,
  });

  factory TrackingEvent.fromJson(Map<String, dynamic> json) {
    // OTM returns stop number inside stops.items[0].stopSequence
    // There is no shipmentStopNum at the root level
    final stopItems = json['stops']?['items'] as List?;
    final stopNum = stopItems != null && stopItems.isNotEmpty
        ? (stopItems[0]['stopSequence'] ?? 0) as int
        : (json['shipmentStopNum'] ?? 0) as int;  // fallback for old API shape

    return TrackingEvent(
      transactionNo: json['iTransactionNo'] ?? 0,
      statusCodeGid: json['statusCodeGid'] ?? '',
      shipmentStopNum: stopNum,
      eventLocationGid: json['eventLocationGid'] ?? '',
      eventDate: json['eventdate']?['value'] ?? '',
      reportingMethod: json['reportingMethod'] ?? '',
    );
  }
}

// ─── Shipment Detail ──────────────────────────────────────────────────────────

class ShipmentDetail {
  final String shipmentXid;
  final String? startTime;
  final String? endTime;
  final WeightInfo? totalWeight;
  final String domainName;
  final LocationDetail? sourceLocation;
  final LocationDetail? destLocation;
  final List<ShipmentStatus> statuses;
  final List<ShipmentStop> stops;
  final List<TrackingEvent> trackingEvents;
  final int numStops;

  ShipmentDetail({
    required this.shipmentXid,
    this.startTime,
    this.endTime,
    this.totalWeight,
    required this.domainName,
    this.sourceLocation,
    this.destLocation,
    required this.statuses,
    required this.stops,
    required this.trackingEvents,
    required this.numStops,
  });

  factory ShipmentDetail.fromJson(Map<String, dynamic> json) {
    return ShipmentDetail(
      shipmentXid: json['shipmentXid'] ?? '',
      startTime: json['startTime']?['value'],
      endTime: json['endTime']?['value'],
      totalWeight: json['totalWeight'] != null
          ? WeightInfo.fromJson(json['totalWeight'])
          : null,
      domainName: json['domainName'] ?? '',
      sourceLocation: json['sourceLocation'] != null
          ? LocationDetail.fromJson(json['sourceLocation'])
          : null,
      destLocation: json['destLocation'] != null
          ? LocationDetail.fromJson(json['destLocation'])
          : null,
      statuses: json['statuses'] != null && json['statuses']['items'] != null
          ? (json['statuses']['items'] as List)
              .map((s) => ShipmentStatus.fromJson(s))
              .toList()
          : [],
      stops: json['stops'] != null && json['stops']['items'] != null
          ? (json['stops']['items'] as List)
              .map((s) => ShipmentStop.fromJson(s))
              .toList()
          : [],
      trackingEvents:
          json['trackingEvents'] != null && json['trackingEvents']['items'] != null
              ? (json['trackingEvents']['items'] as List)
                  .map((e) => TrackingEvent.fromJson(e))
                  .toList()
              : [],
      numStops: json['numStops'] ?? 0,
    );
  }

  /// Get the overall trip status from statuses list
  String get tripStatus {
    final tripStatus = statuses.firstWhere(
      (s) => s.statusTypeGid.contains('TRIP'),
      orElse: () => ShipmentStatus(
          statusTypeGid: '', statusValueGid: 'NOT_STARTED'),
    );
    final value = tripStatus.statusValueGid;
    if (value.contains('NOT_STARTED')) return 'NOT_STARTED';
    if (value.contains('IN_PROGRESS')) return 'IN_PROGRESS';
    if (value.contains('COMPLETED')) return 'COMPLETED';
    return 'NOT_STARTED';
  }

  /// Get tracking events for a specific stop
  List<TrackingEvent> eventsForStop(int stopNum) {
    return trackingEvents
        .where((e) => e.shipmentStopNum == stopNum)
        .toList();
  }
}