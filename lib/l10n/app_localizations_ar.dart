// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Leap Driver';

  @override
  String get checkSms => 'تحقق من رسائلك';

  @override
  String get smsInstruction =>
      'اضغط على رابط الشحنة المرسل إلى هاتفك لفتح رحلتك.';

  @override
  String get openSmsApp => 'افتح تطبيق الرسائل';

  @override
  String get smsTapInstruction =>
      'اضغط على الرابط المرسل من المرسل لبدء العمل.';

  @override
  String get noLoginRequired => 'لا يلزم تسجيل الدخول · الوصول عبر رابط SMS';

  @override
  String get loadingShipment => 'جارٍ تحميل الشحنة...';

  @override
  String get unableToLoad => 'تعذّر التحميل';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get shipment => 'الشحنة';

  @override
  String get notStarted => 'لم تبدأ';

  @override
  String get headingToPickup => 'في الطريق للاستلام';

  @override
  String get inTransit => 'في الطريق';

  @override
  String get allStopsDone => 'تمت جميع المحطات · جاهز للإنهاء';

  @override
  String get tripCompleted => 'اكتملت الرحلة';

  @override
  String stopProgress(int done, int total) {
    return 'المحطة $done من $total';
  }

  @override
  String stopsNotStarted(int total) {
    return '$total محطات · لم تبدأ';
  }

  @override
  String get pendingAcceptance => 'في انتظار القبول';

  @override
  String get accepted => 'مقبول';

  @override
  String get enRoutePickup => 'في الطريق للاستلام';

  @override
  String get atPickup => 'عند الاستلام';

  @override
  String get atDelivery => 'عند التسليم';

  @override
  String get delivered => 'تم التسليم';

  @override
  String get completed => 'مكتمل';

  @override
  String get declined => 'مرفوض';

  @override
  String get acceptLoad => '✓  قبول الحمولة';

  @override
  String get startTrip => '▶  بدء الرحلة';

  @override
  String get arrivedAtPickup => '📍  وصلت لنقطة الاستلام';

  @override
  String get loaded => '✅  تم التحميل';

  @override
  String get arrivedAtDelivery => '📍  وصلت لنقطة التسليم';

  @override
  String get deliveredBtn => '✅  تم التسليم';

  @override
  String get completeTrip => '🏁  إنهاء الرحلة';

  @override
  String get uploadPodToComplete => '🔒  ارفع POD لإنهاء الرحلة';

  @override
  String get declineLoad => 'رفض الحمولة';

  @override
  String get callPickup => 'اتصال\nاستلام';

  @override
  String get navigate => 'التنقل';

  @override
  String get pod => 'POD';

  @override
  String get uploadPod => 'رفع POD';

  @override
  String get callDelivery => 'اتصال\nتسليم';

  @override
  String get issue => 'مشكلة';

  @override
  String get loadInformation => 'معلومات الحمولة';

  @override
  String get routeSection => '📍  المسار';

  @override
  String get loadDetailsSection => '📦  تفاصيل الحمولة';

  @override
  String get origin => 'المنشأ';

  @override
  String get destination => 'الوجهة';

  @override
  String get pickup => 'الاستلام';

  @override
  String get delivery => 'التسليم';

  @override
  String get stops => 'المحطات';

  @override
  String get distance => 'المسافة';

  @override
  String get equipment => 'المعدات';

  @override
  String get weight => 'الوزن';

  @override
  String get hazardous => 'خطر';

  @override
  String get tempControl => 'التحكم بالحرارة';

  @override
  String get yes => '⚠️  نعم';

  @override
  String get no => '✓  لا';

  @override
  String get yesTemp => '❄️  نعم';

  @override
  String get stopTimeline => 'المحطات';

  @override
  String get allDone => 'جميعها مكتملة ✓';

  @override
  String get done => 'مكتمل';

  @override
  String get headingHere => '🚛 في الطريق إليها';

  @override
  String get youAreHere => '📍 أنت هنا';

  @override
  String get upNext => '⏳ التالية';

  @override
  String get upcoming => '⏳ القادمة';

  @override
  String get recordedEvents => 'الأحداث المسجّلة';

  @override
  String get arrivedAtStop => 'وصلت إلى المحطة';

  @override
  String get leftStop => 'غادرت المحطة';

  @override
  String get podSubmitted => 'تم إرسال POD';

  @override
  String get podReminderBanner => '⚠️  POD مطلوب — ارفعه قبل إنهاء الرحلة';

  @override
  String get reportIssue => 'الإبلاغ عن مشكلة';

  @override
  String get dispatcherNotified => 'سيتم إخطار المرسل فوراً.';

  @override
  String get delay => 'تأخير';

  @override
  String get breakdown => 'عطل';

  @override
  String get damage => 'تلف';

  @override
  String get dispatcherNotifiedMsg => 'تم إخطار المرسل';

  @override
  String get locationSharing => 'مشاركة الموقع';

  @override
  String get shareMyLocation => 'مشاركة موقعي';

  @override
  String get updatesAutomatically => 'يتحدث تلقائياً أثناء القيادة.';

  @override
  String get yourDispatcherSees => 'يرى المرسل موقعك أثناء الرحلة.';

  @override
  String get locationSharingOn => 'مشاركة الموقع مفعّلة';

  @override
  String get locationSharingOff => 'مشاركة الموقع معطّلة';

  @override
  String get save => 'حفظ';

  @override
  String get sharingLocation => 'جارٍ مشاركة الموقع';

  @override
  String get locationPaused => 'الموقع متوقف مؤقتاً';

  @override
  String get locationOn => 'الموقع مفعّل';

  @override
  String get locationOff => 'الموقع معطّل';

  @override
  String get pauseTracking => 'إيقاف التتبع مؤقتاً؟';

  @override
  String get pauseTrackingMsg => 'ستتوقف إشارات الموقع فوراً';

  @override
  String get pauseWarning => 'لن يرى المرسل موقعك. اضغط على الشارة للاستئناف.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get pauseTrackingBtn => 'إيقاف التتبع';

  @override
  String get confirmAction => 'تأكيد الإجراء';

  @override
  String get youAreAboutTo => 'أنت على وشك:';

  @override
  String get cannotBeUndone => 'لا يمكن التراجع عن هذا.';

  @override
  String get yesConfirm => 'نعم، تأكيد';

  @override
  String get reasonForDeclining => 'سبب الرفض';

  @override
  String get selectReasonBelow => 'اختر السبب أدناه';

  @override
  String get vehicleIssue => 'مشكلة في المركبة';

  @override
  String get personalEmergency => 'طارئ شخصي';

  @override
  String get routeTooLong => 'المسار طويل جداً';

  @override
  String get lowRate => 'الأجر منخفض';

  @override
  String get other => 'أخرى';

  @override
  String get selectReasonFirst => 'اختر سبباً أولاً.';

  @override
  String get confirmDecline => 'تأكيد الرفض';

  @override
  String get documents => 'المستندات';

  @override
  String uploadedCount(int count) {
    return '$count / 4 مرفوعة';
  }

  @override
  String get podSigned => 'POD (موقّع)';

  @override
  String get podMandatory => 'إلزامي قبل إنهاء الرحلة';

  @override
  String get eWayBill => 'E-Way Bill';

  @override
  String get invoiceCopy => 'نسخة الفاتورة';

  @override
  String get damagePhoto => 'صورة التلف';

  @override
  String get optional => 'اختياري';

  @override
  String get required => 'مطلوب';

  @override
  String get uploaded => '✓ تم الرفع';

  @override
  String get podUploadedMsg => 'تم رفع POD ✓ — يمكنك الآن إنهاء الرحلة';

  @override
  String get uploadPodFirst => 'يرجى رفع POD أولاً';

  @override
  String get callPickupContact => 'جهة اتصال الاستلام';

  @override
  String get callDeliveryContact => 'جهة اتصال التسليم';

  @override
  String get callNow => 'اتصل الآن';

  @override
  String get callingMsg => 'جارٍ الاتصال بـ';

  @override
  String get callingDispatcher => 'جارٍ الاتصال بالمرسل...';

  @override
  String get tripCompletedTitle => 'اكتملت الرحلة!';

  @override
  String get tripCompletedSubtitle => 'تم تسليم الشحنة بنجاح.';

  @override
  String get callDispatcher => 'الاتصال بالمرسل';

  @override
  String get podSubmittedBadge => 'تم إرسال POD';

  @override
  String get tripClosedBadge => 'الرحلة مغلقة';

  @override
  String get loadDeclined => 'تم رفض الحمولة';

  @override
  String get youHaveDeclined => 'لقد رفضت هذه الحمولة.';

  @override
  String get declinedMistake => 'إذا كان ذلك خطأً، اتصل بمرسلك.';

  @override
  String get couldNotUpdate => 'تعذّر تحديث الحالة. حاول مرة أخرى.';

  @override
  String get openingMaps => 'فتح الخرائط إلى';

  @override
  String get failedMsg => 'فشل';
}
