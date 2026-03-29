// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Leap Driver';

  @override
  String get checkSms => 'Check your SMS';

  @override
  String get smsInstruction =>
      'Tap the shipment link sent to your phone to open your trip.';

  @override
  String get openSmsApp => 'Open your SMS app';

  @override
  String get smsTapInstruction =>
      'Tap the shipment link sent by your dispatcher to get started.';

  @override
  String get noLoginRequired =>
      'No login required · Access is provided via SMS link';

  @override
  String get loadingShipment => 'Loading shipment...';

  @override
  String get unableToLoad => 'Unable to Load';

  @override
  String get retry => 'Retry';

  @override
  String get noData => 'No data';

  @override
  String get shipment => 'SHIPMENT';

  @override
  String get notStarted => 'Not started';

  @override
  String get headingToPickup => 'Heading to pickup';

  @override
  String get inTransit => 'In transit';

  @override
  String get allStopsDone => 'All stops done · Ready to complete';

  @override
  String get tripCompleted => 'Trip completed';

  @override
  String stopProgress(int done, int total) {
    return 'Stop $done of $total';
  }

  @override
  String stopsNotStarted(int total) {
    return '$total stops · Not started';
  }

  @override
  String get pendingAcceptance => 'Pending Acceptance';

  @override
  String get accepted => 'Accepted';

  @override
  String get enRoutePickup => 'En Route Pickup';

  @override
  String get atPickup => 'At Pickup';

  @override
  String get atDelivery => 'At Delivery';

  @override
  String get delivered => 'Delivered';

  @override
  String get completed => 'Completed';

  @override
  String get declined => 'Declined';

  @override
  String get acceptLoad => '✓  Accept Load';

  @override
  String get startTrip => '▶  Start Trip';

  @override
  String get arrivedAtPickup => '📍  Arrived at Pickup';

  @override
  String get loaded => '✅  Loaded';

  @override
  String get arrivedAtDelivery => '📍  Arrived at Delivery';

  @override
  String get deliveredBtn => '✅  Delivered';

  @override
  String get completeTrip => '🏁  Complete Trip';

  @override
  String get uploadPodToComplete => '🔒  Upload POD to Complete';

  @override
  String get declineLoad => 'Decline Load';

  @override
  String get callPickup => 'Call\nPickup';

  @override
  String get navigate => 'Navigate';

  @override
  String get pod => 'POD';

  @override
  String get uploadPod => 'Upload POD';

  @override
  String get callDelivery => 'Call\nDelivery';

  @override
  String get issue => 'Issue';

  @override
  String get loadInformation => 'LOAD INFORMATION';

  @override
  String get routeSection => '📍  Route';

  @override
  String get loadDetailsSection => '📦  Load Details';

  @override
  String get origin => 'Origin';

  @override
  String get destination => 'Destination';

  @override
  String get pickup => 'Pickup';

  @override
  String get delivery => 'Delivery';

  @override
  String get stops => 'STOPS';

  @override
  String get distance => 'Distance';

  @override
  String get equipment => 'Equipment';

  @override
  String get weight => 'Weight';

  @override
  String get hazardous => 'Hazardous';

  @override
  String get tempControl => 'Temp Control';

  @override
  String get yes => '⚠️  Yes';

  @override
  String get no => '✓  No';

  @override
  String get yesTemp => '❄️  Yes';

  @override
  String get stopTimeline => 'Stops';

  @override
  String get allDone => 'All done ✓';

  @override
  String get done => 'Done';

  @override
  String get headingHere => '🚛 Heading here';

  @override
  String get youAreHere => '📍 You are here';

  @override
  String get upNext => '⏳ Up next';

  @override
  String get upcoming => '⏳ Upcoming';

  @override
  String get recordedEvents => 'RECORDED EVENTS';

  @override
  String get arrivedAtStop => 'Arrived at stop';

  @override
  String get leftStop => 'Left the stop';

  @override
  String get podSubmitted => 'POD submitted';

  @override
  String get podReminderBanner =>
      '⚠️  POD required — upload before completing trip';

  @override
  String get reportIssue => 'Report an Issue';

  @override
  String get dispatcherNotified =>
      'Your dispatcher will be notified immediately.';

  @override
  String get delay => 'Delay';

  @override
  String get breakdown => 'Breakdown';

  @override
  String get damage => 'Damage';

  @override
  String get dispatcherNotifiedMsg => 'Dispatcher has been notified';

  @override
  String get locationSharing => 'Location Sharing';

  @override
  String get shareMyLocation => 'Share my location';

  @override
  String get updatesAutomatically => 'Updates automatically while you drive.';

  @override
  String get yourDispatcherSees =>
      'Your dispatcher sees your location during the trip.';

  @override
  String get locationSharingOn => 'Location sharing is on';

  @override
  String get locationSharingOff => 'Location sharing is off';

  @override
  String get save => 'Save';

  @override
  String get sharingLocation => 'Sharing location';

  @override
  String get locationPaused => 'Location paused';

  @override
  String get locationOn => 'Location on';

  @override
  String get locationOff => 'Location off';

  @override
  String get pauseTracking => 'Pause Live Tracking?';

  @override
  String get pauseTrackingMsg => 'Location pings will stop immediately';

  @override
  String get pauseWarning =>
      'The dispatcher will no longer see your live position. Tap the Live badge to resume.';

  @override
  String get cancel => 'Cancel';

  @override
  String get pauseTrackingBtn => 'Pause Tracking';

  @override
  String get confirmAction => 'Confirm Action';

  @override
  String get youAreAboutTo => 'You are about to:';

  @override
  String get cannotBeUndone => 'This cannot be undone.';

  @override
  String get yesConfirm => 'Yes, Confirm';

  @override
  String get reasonForDeclining => 'Reason for Declining';

  @override
  String get selectReasonBelow => 'Select the reason below';

  @override
  String get vehicleIssue => 'Vehicle Issue';

  @override
  String get personalEmergency => 'Personal Emergency';

  @override
  String get routeTooLong => 'Route Too Long';

  @override
  String get lowRate => 'Low Rate';

  @override
  String get other => 'Other';

  @override
  String get selectReasonFirst => 'Select a reason first.';

  @override
  String get confirmDecline => 'Confirm Decline';

  @override
  String get documents => 'Documents';

  @override
  String uploadedCount(int count) {
    return '$count / 4 uploaded';
  }

  @override
  String get podSigned => 'POD (Signed)';

  @override
  String get podMandatory => 'Mandatory before trip completion';

  @override
  String get eWayBill => 'E-Way Bill';

  @override
  String get invoiceCopy => 'Invoice Copy';

  @override
  String get damagePhoto => 'Damage Photo';

  @override
  String get optional => 'Optional';

  @override
  String get required => 'Required';

  @override
  String get uploaded => '✓ Uploaded';

  @override
  String get podUploadedMsg => 'POD uploaded ✓ — you can now complete the trip';

  @override
  String get uploadPodFirst => 'Please upload your POD first';

  @override
  String get callPickupContact => 'Pickup Contact';

  @override
  String get callDeliveryContact => 'Delivery Contact';

  @override
  String get callNow => 'Call Now';

  @override
  String get callingMsg => 'Calling';

  @override
  String get callingDispatcher => 'Calling dispatcher...';

  @override
  String get tripCompletedTitle => 'Trip Completed!';

  @override
  String get tripCompletedSubtitle => 'Shipment delivered successfully.';

  @override
  String get callDispatcher => 'Call Dispatcher';

  @override
  String get podSubmittedBadge => 'POD submitted';

  @override
  String get tripClosedBadge => 'Trip closed';

  @override
  String get loadDeclined => 'Load Declined';

  @override
  String get youHaveDeclined => 'You have declined this load.';

  @override
  String get declinedMistake =>
      'If this was a mistake, please call your dispatcher.';

  @override
  String get couldNotUpdate => 'Could not update status. Please try again.';

  @override
  String get openingMaps => 'Opening maps to';

  @override
  String get failedMsg => 'Failed';
}
