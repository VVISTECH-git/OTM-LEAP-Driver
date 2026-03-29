// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Leap Driver';

  @override
  String get checkSms => 'SMS prüfen';

  @override
  String get smsInstruction =>
      'Tippe auf den Sendungslink auf deinem Telefon, um deine Fahrt zu öffnen.';

  @override
  String get openSmsApp => 'SMS-App öffnen';

  @override
  String get smsTapInstruction =>
      'Tippe auf den Link deines Disponenten, um zu beginnen.';

  @override
  String get noLoginRequired => 'Kein Login erforderlich · Zugang per SMS-Link';

  @override
  String get loadingShipment => 'Sendung wird geladen...';

  @override
  String get unableToLoad => 'Laden fehlgeschlagen';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get noData => 'Keine Daten';

  @override
  String get shipment => 'SENDUNG';

  @override
  String get notStarted => 'Nicht gestartet';

  @override
  String get headingToPickup => 'Auf dem Weg zur Abholung';

  @override
  String get inTransit => 'Unterwegs';

  @override
  String get allStopsDone => 'Alle Stopps erledigt · Bereit zum Abschließen';

  @override
  String get tripCompleted => 'Fahrt abgeschlossen';

  @override
  String stopProgress(int done, int total) {
    return 'Stopp $done von $total';
  }

  @override
  String stopsNotStarted(int total) {
    return '$total Stopps · Nicht gestartet';
  }

  @override
  String get pendingAcceptance => 'Wartet auf Annahme';

  @override
  String get accepted => 'Angenommen';

  @override
  String get enRoutePickup => 'Unterwegs zur Abholung';

  @override
  String get atPickup => 'Bei Abholung';

  @override
  String get atDelivery => 'Bei Lieferung';

  @override
  String get delivered => 'Geliefert';

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get declined => 'Abgelehnt';

  @override
  String get acceptLoad => '✓  Ladung annehmen';

  @override
  String get startTrip => '▶  Fahrt starten';

  @override
  String get arrivedAtPickup => '📍  Abholung angekommen';

  @override
  String get loaded => '✅  Beladen';

  @override
  String get arrivedAtDelivery => '📍  Lieferung angekommen';

  @override
  String get deliveredBtn => '✅  Geliefert';

  @override
  String get completeTrip => '🏁  Fahrt abschließen';

  @override
  String get uploadPodToComplete => '🔒  POD hochladen zum Abschließen';

  @override
  String get declineLoad => 'Ladung ablehnen';

  @override
  String get callPickup => 'Anrufen\nAbholung';

  @override
  String get navigate => 'Navigieren';

  @override
  String get pod => 'POD';

  @override
  String get uploadPod => 'POD hochladen';

  @override
  String get callDelivery => 'Anrufen\nLieferung';

  @override
  String get issue => 'Problem';

  @override
  String get loadInformation => 'LADUNGSINFORMATIONEN';

  @override
  String get routeSection => '📍  Route';

  @override
  String get loadDetailsSection => '📦  Ladungsdetails';

  @override
  String get origin => 'Herkunft';

  @override
  String get destination => 'Ziel';

  @override
  String get pickup => 'Abholung';

  @override
  String get delivery => 'Lieferung';

  @override
  String get stops => 'STOPPS';

  @override
  String get distance => 'Entfernung';

  @override
  String get equipment => 'Ausrüstung';

  @override
  String get weight => 'Gewicht';

  @override
  String get hazardous => 'Gefährlich';

  @override
  String get tempControl => 'Temperaturkontrolle';

  @override
  String get yes => '⚠️  Ja';

  @override
  String get no => '✓  Nein';

  @override
  String get yesTemp => '❄️  Ja';

  @override
  String get stopTimeline => 'Stopps';

  @override
  String get allDone => 'Alle erledigt ✓';

  @override
  String get done => 'Erledigt';

  @override
  String get headingHere => '🚛 Auf dem Weg';

  @override
  String get youAreHere => '📍 Du bist hier';

  @override
  String get upNext => '⏳ Als Nächstes';

  @override
  String get upcoming => '⏳ Bevorstehend';

  @override
  String get recordedEvents => 'AUFGEZEICHNETE EREIGNISSE';

  @override
  String get arrivedAtStop => 'Am Stopp angekommen';

  @override
  String get leftStop => 'Stopp verlassen';

  @override
  String get podSubmitted => 'POD übermittelt';

  @override
  String get podReminderBanner =>
      '⚠️  POD erforderlich — vor Fahrtende hochladen';

  @override
  String get reportIssue => 'Problem melden';

  @override
  String get dispatcherNotified => 'Dein Disponent wird sofort benachrichtigt.';

  @override
  String get delay => 'Verzögerung';

  @override
  String get breakdown => 'Panne';

  @override
  String get damage => 'Schaden';

  @override
  String get dispatcherNotifiedMsg => 'Disponent benachrichtigt';

  @override
  String get locationSharing => 'Standortfreigabe';

  @override
  String get shareMyLocation => 'Meinen Standort teilen';

  @override
  String get updatesAutomatically =>
      'Wird während der Fahrt automatisch aktualisiert.';

  @override
  String get yourDispatcherSees =>
      'Dein Disponent sieht deinen Standort während der Fahrt.';

  @override
  String get locationSharingOn => 'Standortfreigabe aktiviert';

  @override
  String get locationSharingOff => 'Standortfreigabe deaktiviert';

  @override
  String get save => 'Speichern';

  @override
  String get sharingLocation => 'Standort wird geteilt';

  @override
  String get locationPaused => 'Standort pausiert';

  @override
  String get locationOn => 'Standort an';

  @override
  String get locationOff => 'Standort aus';

  @override
  String get pauseTracking => 'Tracking pausieren?';

  @override
  String get pauseTrackingMsg => 'Standort-Pings werden sofort gestoppt';

  @override
  String get pauseWarning =>
      'Der Disponent sieht deinen Standort nicht mehr. Tippe auf das Badge zum Fortsetzen.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get pauseTrackingBtn => 'Tracking pausieren';

  @override
  String get confirmAction => 'Aktion bestätigen';

  @override
  String get youAreAboutTo => 'Du bist dabei:';

  @override
  String get cannotBeUndone => 'Dies kann nicht rückgängig gemacht werden.';

  @override
  String get yesConfirm => 'Ja, bestätigen';

  @override
  String get reasonForDeclining => 'Ablehnungsgrund';

  @override
  String get selectReasonBelow => 'Wähle unten einen Grund aus';

  @override
  String get vehicleIssue => 'Fahrzeugproblem';

  @override
  String get personalEmergency => 'Persönlicher Notfall';

  @override
  String get routeTooLong => 'Route zu lang';

  @override
  String get lowRate => 'Niedriger Tarif';

  @override
  String get other => 'Sonstiges';

  @override
  String get selectReasonFirst => 'Bitte zuerst einen Grund auswählen.';

  @override
  String get confirmDecline => 'Ablehnung bestätigen';

  @override
  String get documents => 'Dokumente';

  @override
  String uploadedCount(int count) {
    return '$count / 4 hochgeladen';
  }

  @override
  String get podSigned => 'POD (Unterschrieben)';

  @override
  String get podMandatory => 'Pflicht vor Fahrtende';

  @override
  String get eWayBill => 'E-Way Bill';

  @override
  String get invoiceCopy => 'Rechnungskopie';

  @override
  String get damagePhoto => 'Schadensfoto';

  @override
  String get optional => 'Optional';

  @override
  String get required => 'Erforderlich';

  @override
  String get uploaded => '✓ Hochgeladen';

  @override
  String get podUploadedMsg =>
      'POD hochgeladen ✓ — du kannst die Fahrt abschließen';

  @override
  String get uploadPodFirst => 'Bitte erst POD hochladen';

  @override
  String get callPickupContact => 'Abholkontakt';

  @override
  String get callDeliveryContact => 'Lieferkontakt';

  @override
  String get callNow => 'Jetzt anrufen';

  @override
  String get callingMsg => 'Rufe an';

  @override
  String get callingDispatcher => 'Rufe Disponenten an...';

  @override
  String get tripCompletedTitle => 'Fahrt abgeschlossen!';

  @override
  String get tripCompletedSubtitle => 'Sendung erfolgreich zugestellt.';

  @override
  String get callDispatcher => 'Disponenten anrufen';

  @override
  String get podSubmittedBadge => 'POD übermittelt';

  @override
  String get tripClosedBadge => 'Fahrt geschlossen';

  @override
  String get loadDeclined => 'Ladung abgelehnt';

  @override
  String get youHaveDeclined => 'Du hast diese Ladung abgelehnt.';

  @override
  String get declinedMistake =>
      'Falls das ein Fehler war, ruf deinen Disponenten an.';

  @override
  String get couldNotUpdate =>
      'Status konnte nicht aktualisiert werden. Erneut versuchen.';

  @override
  String get openingMaps => 'Karten öffnen nach';

  @override
  String get failedMsg => 'Fehlgeschlagen';
}
