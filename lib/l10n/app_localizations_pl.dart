// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Leap Driver';

  @override
  String get checkSms => 'Sprawdź SMS';

  @override
  String get smsInstruction =>
      'Kliknij link przesyłki wysłany na Twój telefon, aby otworzyć trasę.';

  @override
  String get openSmsApp => 'Otwórz aplikację SMS';

  @override
  String get smsTapInstruction =>
      'Kliknij link przesyłki wysłany przez dyspozytora, aby rozpocząć.';

  @override
  String get noLoginRequired => 'Bez logowania · Dostęp przez link SMS';

  @override
  String get loadingShipment => 'Ładowanie przesyłki...';

  @override
  String get unableToLoad => 'Nie można załadować';

  @override
  String get retry => 'Spróbuj ponownie';

  @override
  String get noData => 'Brak danych';

  @override
  String get shipment => 'PRZESYŁKA';

  @override
  String get notStarted => 'Nie rozpoczęto';

  @override
  String get headingToPickup => 'W drodze po odbiór';

  @override
  String get inTransit => 'W transporcie';

  @override
  String get allStopsDone =>
      'Wszystkie przystanki ukończone · Gotowy do zakończenia';

  @override
  String get tripCompleted => 'Trasa zakończona';

  @override
  String stopProgress(int done, int total) {
    return 'Przystanek $done z $total';
  }

  @override
  String stopsNotStarted(int total) {
    return '$total przystanki · Nie rozpoczęto';
  }

  @override
  String get pendingAcceptance => 'Oczekuje na Akceptację';

  @override
  String get accepted => 'Zaakceptowano';

  @override
  String get enRoutePickup => 'W Drodze po Odbiór';

  @override
  String get atPickup => 'Na Odbiorze';

  @override
  String get atDelivery => 'Na Dostawie';

  @override
  String get delivered => 'Dostarczone';

  @override
  String get completed => 'Ukończono';

  @override
  String get declined => 'Odrzucono';

  @override
  String get acceptLoad => '✓  Akceptuj Ładunek';

  @override
  String get startTrip => '▶  Rozpocznij Trasę';

  @override
  String get arrivedAtPickup => '📍  Dotarłem do Odbioru';

  @override
  String get loaded => '✅  Załadowano';

  @override
  String get arrivedAtDelivery => '📍  Dotarłem do Dostawy';

  @override
  String get deliveredBtn => '✅  Dostarczone';

  @override
  String get completeTrip => '🏁  Zakończ Trasę';

  @override
  String get uploadPodToComplete => '🔒  Wyślij POD aby Zakończyć';

  @override
  String get declineLoad => 'Odrzuć Ładunek';

  @override
  String get callPickup => 'Zadzwoń\nOdbiór';

  @override
  String get navigate => 'Nawiguj';

  @override
  String get pod => 'POD';

  @override
  String get uploadPod => 'Wyślij POD';

  @override
  String get callDelivery => 'Zadzwoń\nDostawa';

  @override
  String get issue => 'Problem';

  @override
  String get loadInformation => 'INFORMACJE O ŁADUNKU';

  @override
  String get routeSection => '📍  Trasa';

  @override
  String get loadDetailsSection => '📦  Szczegóły Ładunku';

  @override
  String get origin => 'Skąd';

  @override
  String get destination => 'Dokąd';

  @override
  String get pickup => 'Odbiór';

  @override
  String get delivery => 'Dostawa';

  @override
  String get stops => 'PRZYSTANKI';

  @override
  String get distance => 'Odległość';

  @override
  String get equipment => 'Sprzęt';

  @override
  String get weight => 'Waga';

  @override
  String get hazardous => 'Niebezpieczny';

  @override
  String get tempControl => 'Kontrola Temp';

  @override
  String get yes => '⚠️  Tak';

  @override
  String get no => '✓  Nie';

  @override
  String get yesTemp => '❄️  Tak';

  @override
  String get stopTimeline => 'Przystanki';

  @override
  String get allDone => 'Wszystkie ukończone ✓';

  @override
  String get done => 'Ukończono';

  @override
  String get headingHere => '🚛 Jadę tutaj';

  @override
  String get youAreHere => '📍 Jesteś tutaj';

  @override
  String get upNext => '⏳ Następny';

  @override
  String get upcoming => '⏳ Nadchodzący';

  @override
  String get recordedEvents => 'ZAPISANE ZDARZENIA';

  @override
  String get arrivedAtStop => 'Dotarłem do przystanku';

  @override
  String get leftStop => 'Opuściłem przystanek';

  @override
  String get podSubmitted => 'POD wysłany';

  @override
  String get podReminderBanner =>
      '⚠️  Wymagany POD — wyślij przed zakończeniem trasy';

  @override
  String get reportIssue => 'Zgłoś Problem';

  @override
  String get dispatcherNotified =>
      'Dyspozytor zostanie natychmiast powiadomiony.';

  @override
  String get delay => 'Opóźnienie';

  @override
  String get breakdown => 'Awaria';

  @override
  String get damage => 'Uszkodzenie';

  @override
  String get dispatcherNotifiedMsg => 'Dyspozytor powiadomiony';

  @override
  String get locationSharing => 'Udostępnianie Lokalizacji';

  @override
  String get shareMyLocation => 'Udostępnij moją lokalizację';

  @override
  String get updatesAutomatically => 'Aktualizuje automatycznie podczas jazdy.';

  @override
  String get yourDispatcherSees =>
      'Dyspozytor widzi Twoją lokalizację podczas trasy.';

  @override
  String get locationSharingOn => 'Udostępnianie lokalizacji włączone';

  @override
  String get locationSharingOff => 'Udostępnianie lokalizacji wyłączone';

  @override
  String get save => 'Zapisz';

  @override
  String get sharingLocation => 'Udostępnianie lokalizacji';

  @override
  String get locationPaused => 'Lokalizacja wstrzymana';

  @override
  String get locationOn => 'Lokalizacja włączona';

  @override
  String get locationOff => 'Lokalizacja wyłączona';

  @override
  String get pauseTracking => 'Wstrzymać Śledzenie?';

  @override
  String get pauseTrackingMsg => 'Pingi lokalizacji zostaną zatrzymane';

  @override
  String get pauseWarning =>
      'Dyspozytor nie będzie widział Twojej pozycji. Dotknij badge, aby wznowić.';

  @override
  String get cancel => 'Anuluj';

  @override
  String get pauseTrackingBtn => 'Wstrzymaj Śledzenie';

  @override
  String get confirmAction => 'Potwierdź Działanie';

  @override
  String get youAreAboutTo => 'Zamierzasz:';

  @override
  String get cannotBeUndone => 'Tego nie można cofnąć.';

  @override
  String get yesConfirm => 'Tak, Potwierdź';

  @override
  String get reasonForDeclining => 'Powód Odrzucenia';

  @override
  String get selectReasonBelow => 'Wybierz powód poniżej';

  @override
  String get vehicleIssue => 'Problem z Pojazdem';

  @override
  String get personalEmergency => 'Nagły Przypadek';

  @override
  String get routeTooLong => 'Trasa Zbyt Długa';

  @override
  String get lowRate => 'Niska Stawka';

  @override
  String get other => 'Inny';

  @override
  String get selectReasonFirst => 'Najpierw wybierz powód.';

  @override
  String get confirmDecline => 'Potwierdź Odrzucenie';

  @override
  String get documents => 'Dokumenty';

  @override
  String uploadedCount(int count) {
    return '$count / 4 wysłane';
  }

  @override
  String get podSigned => 'POD (Podpisany)';

  @override
  String get podMandatory => 'Obowiązkowy przed zakończeniem trasy';

  @override
  String get eWayBill => 'E-Way Bill';

  @override
  String get invoiceCopy => 'Kopia Faktury';

  @override
  String get damagePhoto => 'Zdjęcie Uszkodzenia';

  @override
  String get optional => 'Opcjonalny';

  @override
  String get required => 'Wymagany';

  @override
  String get uploaded => '✓ Wysłano';

  @override
  String get podUploadedMsg => 'POD wysłany ✓ — możesz zakończyć trasę';

  @override
  String get uploadPodFirst => 'Najpierw wyślij swój POD';

  @override
  String get callPickupContact => 'Kontakt Odbioru';

  @override
  String get callDeliveryContact => 'Kontakt Dostawy';

  @override
  String get callNow => 'Zadzwoń Teraz';

  @override
  String get callingMsg => 'Dzwonię do';

  @override
  String get callingDispatcher => 'Dzwonię do dyspozytora...';

  @override
  String get tripCompletedTitle => 'Trasa Ukończona!';

  @override
  String get tripCompletedSubtitle => 'Przesyłka dostarczona pomyślnie.';

  @override
  String get callDispatcher => 'Zadzwoń do Dyspozytora';

  @override
  String get podSubmittedBadge => 'POD wysłany';

  @override
  String get tripClosedBadge => 'Trasa zamknięta';

  @override
  String get loadDeclined => 'Ładunek Odrzucony';

  @override
  String get youHaveDeclined => 'Odrzuciłeś ten ładunek.';

  @override
  String get declinedMistake => 'Jeśli to pomyłka, zadzwoń do dyspozytora.';

  @override
  String get couldNotUpdate => 'Nie można zaktualizować. Spróbuj ponownie.';

  @override
  String get openingMaps => 'Otwieranie map do';

  @override
  String get failedMsg => 'Nieudane';
}
