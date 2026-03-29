import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('hi'),
    Locale('pl'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Leap Driver'**
  String get appTitle;

  /// No description provided for @checkSms.
  ///
  /// In en, this message translates to:
  /// **'Check your SMS'**
  String get checkSms;

  /// No description provided for @smsInstruction.
  ///
  /// In en, this message translates to:
  /// **'Tap the shipment link sent to your phone to open your trip.'**
  String get smsInstruction;

  /// No description provided for @openSmsApp.
  ///
  /// In en, this message translates to:
  /// **'Open your SMS app'**
  String get openSmsApp;

  /// No description provided for @smsTapInstruction.
  ///
  /// In en, this message translates to:
  /// **'Tap the shipment link sent by your dispatcher to get started.'**
  String get smsTapInstruction;

  /// No description provided for @noLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'No login required · Access is provided via SMS link'**
  String get noLoginRequired;

  /// No description provided for @loadingShipment.
  ///
  /// In en, this message translates to:
  /// **'Loading shipment...'**
  String get loadingShipment;

  /// No description provided for @unableToLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to Load'**
  String get unableToLoad;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @shipment.
  ///
  /// In en, this message translates to:
  /// **'SHIPMENT'**
  String get shipment;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get notStarted;

  /// No description provided for @headingToPickup.
  ///
  /// In en, this message translates to:
  /// **'Heading to pickup'**
  String get headingToPickup;

  /// No description provided for @inTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get inTransit;

  /// No description provided for @allStopsDone.
  ///
  /// In en, this message translates to:
  /// **'All stops done · Ready to complete'**
  String get allStopsDone;

  /// No description provided for @tripCompleted.
  ///
  /// In en, this message translates to:
  /// **'Trip completed'**
  String get tripCompleted;

  /// No description provided for @stopProgress.
  ///
  /// In en, this message translates to:
  /// **'Stop {done} of {total}'**
  String stopProgress(int done, int total);

  /// No description provided for @stopsNotStarted.
  ///
  /// In en, this message translates to:
  /// **'{total} stops · Not started'**
  String stopsNotStarted(int total);

  /// No description provided for @pendingAcceptance.
  ///
  /// In en, this message translates to:
  /// **'Pending Acceptance'**
  String get pendingAcceptance;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @enRoutePickup.
  ///
  /// In en, this message translates to:
  /// **'En Route Pickup'**
  String get enRoutePickup;

  /// No description provided for @atPickup.
  ///
  /// In en, this message translates to:
  /// **'At Pickup'**
  String get atPickup;

  /// No description provided for @atDelivery.
  ///
  /// In en, this message translates to:
  /// **'At Delivery'**
  String get atDelivery;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @declined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get declined;

  /// No description provided for @acceptLoad.
  ///
  /// In en, this message translates to:
  /// **'✓  Accept Load'**
  String get acceptLoad;

  /// No description provided for @startTrip.
  ///
  /// In en, this message translates to:
  /// **'▶  Start Trip'**
  String get startTrip;

  /// No description provided for @arrivedAtPickup.
  ///
  /// In en, this message translates to:
  /// **'📍  Arrived at Pickup'**
  String get arrivedAtPickup;

  /// No description provided for @loaded.
  ///
  /// In en, this message translates to:
  /// **'✅  Loaded'**
  String get loaded;

  /// No description provided for @arrivedAtDelivery.
  ///
  /// In en, this message translates to:
  /// **'📍  Arrived at Delivery'**
  String get arrivedAtDelivery;

  /// No description provided for @deliveredBtn.
  ///
  /// In en, this message translates to:
  /// **'✅  Delivered'**
  String get deliveredBtn;

  /// No description provided for @completeTrip.
  ///
  /// In en, this message translates to:
  /// **'🏁  Complete Trip'**
  String get completeTrip;

  /// No description provided for @uploadPodToComplete.
  ///
  /// In en, this message translates to:
  /// **'🔒  Upload POD to Complete'**
  String get uploadPodToComplete;

  /// No description provided for @declineLoad.
  ///
  /// In en, this message translates to:
  /// **'Decline Load'**
  String get declineLoad;

  /// No description provided for @callPickup.
  ///
  /// In en, this message translates to:
  /// **'Call\nPickup'**
  String get callPickup;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @pod.
  ///
  /// In en, this message translates to:
  /// **'POD'**
  String get pod;

  /// No description provided for @uploadPod.
  ///
  /// In en, this message translates to:
  /// **'Upload POD'**
  String get uploadPod;

  /// No description provided for @callDelivery.
  ///
  /// In en, this message translates to:
  /// **'Call\nDelivery'**
  String get callDelivery;

  /// No description provided for @issue.
  ///
  /// In en, this message translates to:
  /// **'Issue'**
  String get issue;

  /// No description provided for @loadInformation.
  ///
  /// In en, this message translates to:
  /// **'LOAD INFORMATION'**
  String get loadInformation;

  /// No description provided for @routeSection.
  ///
  /// In en, this message translates to:
  /// **'📍  Route'**
  String get routeSection;

  /// No description provided for @loadDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'📦  Load Details'**
  String get loadDetailsSection;

  /// No description provided for @origin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get origin;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @stops.
  ///
  /// In en, this message translates to:
  /// **'STOPS'**
  String get stops;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @equipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipment;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @hazardous.
  ///
  /// In en, this message translates to:
  /// **'Hazardous'**
  String get hazardous;

  /// No description provided for @tempControl.
  ///
  /// In en, this message translates to:
  /// **'Temp Control'**
  String get tempControl;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'⚠️  Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'✓  No'**
  String get no;

  /// No description provided for @yesTemp.
  ///
  /// In en, this message translates to:
  /// **'❄️  Yes'**
  String get yesTemp;

  /// No description provided for @stopTimeline.
  ///
  /// In en, this message translates to:
  /// **'Stops'**
  String get stopTimeline;

  /// No description provided for @allDone.
  ///
  /// In en, this message translates to:
  /// **'All done ✓'**
  String get allDone;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @headingHere.
  ///
  /// In en, this message translates to:
  /// **'🚛 Heading here'**
  String get headingHere;

  /// No description provided for @youAreHere.
  ///
  /// In en, this message translates to:
  /// **'📍 You are here'**
  String get youAreHere;

  /// No description provided for @upNext.
  ///
  /// In en, this message translates to:
  /// **'⏳ Up next'**
  String get upNext;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'⏳ Upcoming'**
  String get upcoming;

  /// No description provided for @recordedEvents.
  ///
  /// In en, this message translates to:
  /// **'RECORDED EVENTS'**
  String get recordedEvents;

  /// No description provided for @arrivedAtStop.
  ///
  /// In en, this message translates to:
  /// **'Arrived at stop'**
  String get arrivedAtStop;

  /// No description provided for @leftStop.
  ///
  /// In en, this message translates to:
  /// **'Left the stop'**
  String get leftStop;

  /// No description provided for @podSubmitted.
  ///
  /// In en, this message translates to:
  /// **'POD submitted'**
  String get podSubmitted;

  /// No description provided for @podReminderBanner.
  ///
  /// In en, this message translates to:
  /// **'⚠️  POD required — upload before completing trip'**
  String get podReminderBanner;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an Issue'**
  String get reportIssue;

  /// No description provided for @dispatcherNotified.
  ///
  /// In en, this message translates to:
  /// **'Your dispatcher will be notified immediately.'**
  String get dispatcherNotified;

  /// No description provided for @delay.
  ///
  /// In en, this message translates to:
  /// **'Delay'**
  String get delay;

  /// No description provided for @breakdown.
  ///
  /// In en, this message translates to:
  /// **'Breakdown'**
  String get breakdown;

  /// No description provided for @damage.
  ///
  /// In en, this message translates to:
  /// **'Damage'**
  String get damage;

  /// No description provided for @dispatcherNotifiedMsg.
  ///
  /// In en, this message translates to:
  /// **'Dispatcher has been notified'**
  String get dispatcherNotifiedMsg;

  /// No description provided for @locationSharing.
  ///
  /// In en, this message translates to:
  /// **'Location Sharing'**
  String get locationSharing;

  /// No description provided for @shareMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Share my location'**
  String get shareMyLocation;

  /// No description provided for @updatesAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Updates automatically while you drive.'**
  String get updatesAutomatically;

  /// No description provided for @yourDispatcherSees.
  ///
  /// In en, this message translates to:
  /// **'Your dispatcher sees your location during the trip.'**
  String get yourDispatcherSees;

  /// No description provided for @locationSharingOn.
  ///
  /// In en, this message translates to:
  /// **'Location sharing is on'**
  String get locationSharingOn;

  /// No description provided for @locationSharingOff.
  ///
  /// In en, this message translates to:
  /// **'Location sharing is off'**
  String get locationSharingOff;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @sharingLocation.
  ///
  /// In en, this message translates to:
  /// **'Sharing location'**
  String get sharingLocation;

  /// No description provided for @locationPaused.
  ///
  /// In en, this message translates to:
  /// **'Location paused'**
  String get locationPaused;

  /// No description provided for @locationOn.
  ///
  /// In en, this message translates to:
  /// **'Location on'**
  String get locationOn;

  /// No description provided for @locationOff.
  ///
  /// In en, this message translates to:
  /// **'Location off'**
  String get locationOff;

  /// No description provided for @pauseTracking.
  ///
  /// In en, this message translates to:
  /// **'Pause Live Tracking?'**
  String get pauseTracking;

  /// No description provided for @pauseTrackingMsg.
  ///
  /// In en, this message translates to:
  /// **'Location pings will stop immediately'**
  String get pauseTrackingMsg;

  /// No description provided for @pauseWarning.
  ///
  /// In en, this message translates to:
  /// **'The dispatcher will no longer see your live position. Tap the Live badge to resume.'**
  String get pauseWarning;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @pauseTrackingBtn.
  ///
  /// In en, this message translates to:
  /// **'Pause Tracking'**
  String get pauseTrackingBtn;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm Action'**
  String get confirmAction;

  /// No description provided for @youAreAboutTo.
  ///
  /// In en, this message translates to:
  /// **'You are about to:'**
  String get youAreAboutTo;

  /// No description provided for @cannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get cannotBeUndone;

  /// No description provided for @yesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, Confirm'**
  String get yesConfirm;

  /// No description provided for @reasonForDeclining.
  ///
  /// In en, this message translates to:
  /// **'Reason for Declining'**
  String get reasonForDeclining;

  /// No description provided for @selectReasonBelow.
  ///
  /// In en, this message translates to:
  /// **'Select the reason below'**
  String get selectReasonBelow;

  /// No description provided for @vehicleIssue.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Issue'**
  String get vehicleIssue;

  /// No description provided for @personalEmergency.
  ///
  /// In en, this message translates to:
  /// **'Personal Emergency'**
  String get personalEmergency;

  /// No description provided for @routeTooLong.
  ///
  /// In en, this message translates to:
  /// **'Route Too Long'**
  String get routeTooLong;

  /// No description provided for @lowRate.
  ///
  /// In en, this message translates to:
  /// **'Low Rate'**
  String get lowRate;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @selectReasonFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a reason first.'**
  String get selectReasonFirst;

  /// No description provided for @confirmDecline.
  ///
  /// In en, this message translates to:
  /// **'Confirm Decline'**
  String get confirmDecline;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @uploadedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} / 4 uploaded'**
  String uploadedCount(int count);

  /// No description provided for @podSigned.
  ///
  /// In en, this message translates to:
  /// **'POD (Signed)'**
  String get podSigned;

  /// No description provided for @podMandatory.
  ///
  /// In en, this message translates to:
  /// **'Mandatory before trip completion'**
  String get podMandatory;

  /// No description provided for @eWayBill.
  ///
  /// In en, this message translates to:
  /// **'E-Way Bill'**
  String get eWayBill;

  /// No description provided for @invoiceCopy.
  ///
  /// In en, this message translates to:
  /// **'Invoice Copy'**
  String get invoiceCopy;

  /// No description provided for @damagePhoto.
  ///
  /// In en, this message translates to:
  /// **'Damage Photo'**
  String get damagePhoto;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'✓ Uploaded'**
  String get uploaded;

  /// No description provided for @podUploadedMsg.
  ///
  /// In en, this message translates to:
  /// **'POD uploaded ✓ — you can now complete the trip'**
  String get podUploadedMsg;

  /// No description provided for @uploadPodFirst.
  ///
  /// In en, this message translates to:
  /// **'Please upload your POD first'**
  String get uploadPodFirst;

  /// No description provided for @callPickupContact.
  ///
  /// In en, this message translates to:
  /// **'Pickup Contact'**
  String get callPickupContact;

  /// No description provided for @callDeliveryContact.
  ///
  /// In en, this message translates to:
  /// **'Delivery Contact'**
  String get callDeliveryContact;

  /// No description provided for @callNow.
  ///
  /// In en, this message translates to:
  /// **'Call Now'**
  String get callNow;

  /// No description provided for @callingMsg.
  ///
  /// In en, this message translates to:
  /// **'Calling'**
  String get callingMsg;

  /// No description provided for @callingDispatcher.
  ///
  /// In en, this message translates to:
  /// **'Calling dispatcher...'**
  String get callingDispatcher;

  /// No description provided for @tripCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip Completed!'**
  String get tripCompletedTitle;

  /// No description provided for @tripCompletedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shipment delivered successfully.'**
  String get tripCompletedSubtitle;

  /// No description provided for @callDispatcher.
  ///
  /// In en, this message translates to:
  /// **'Call Dispatcher'**
  String get callDispatcher;

  /// No description provided for @podSubmittedBadge.
  ///
  /// In en, this message translates to:
  /// **'POD submitted'**
  String get podSubmittedBadge;

  /// No description provided for @tripClosedBadge.
  ///
  /// In en, this message translates to:
  /// **'Trip closed'**
  String get tripClosedBadge;

  /// No description provided for @loadDeclined.
  ///
  /// In en, this message translates to:
  /// **'Load Declined'**
  String get loadDeclined;

  /// No description provided for @youHaveDeclined.
  ///
  /// In en, this message translates to:
  /// **'You have declined this load.'**
  String get youHaveDeclined;

  /// No description provided for @declinedMistake.
  ///
  /// In en, this message translates to:
  /// **'If this was a mistake, please call your dispatcher.'**
  String get declinedMistake;

  /// No description provided for @couldNotUpdate.
  ///
  /// In en, this message translates to:
  /// **'Could not update status. Please try again.'**
  String get couldNotUpdate;

  /// No description provided for @openingMaps.
  ///
  /// In en, this message translates to:
  /// **'Opening maps to'**
  String get openingMaps;

  /// No description provided for @failedMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failedMsg;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'es',
        'hi',
        'pl',
        'pt'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'hi':
      return AppLocalizationsHi();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
