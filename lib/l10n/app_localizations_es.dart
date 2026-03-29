// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Leap Driver';

  @override
  String get checkSms => 'Revisa tu SMS';

  @override
  String get smsInstruction =>
      'Toca el enlace del envío enviado a tu teléfono para abrir tu viaje.';

  @override
  String get openSmsApp => 'Abre la aplicación de SMS';

  @override
  String get smsTapInstruction =>
      'Toca el enlace enviado por tu despachador para comenzar.';

  @override
  String get noLoginRequired => 'Sin inicio de sesión · Acceso por enlace SMS';

  @override
  String get loadingShipment => 'Cargando envío...';

  @override
  String get unableToLoad => 'No se puede cargar';

  @override
  String get retry => 'Reintentar';

  @override
  String get noData => 'Sin datos';

  @override
  String get shipment => 'ENVÍO';

  @override
  String get notStarted => 'No iniciado';

  @override
  String get headingToPickup => 'En camino a recoger';

  @override
  String get inTransit => 'En tránsito';

  @override
  String get allStopsDone =>
      'Todas las paradas completadas · Listo para finalizar';

  @override
  String get tripCompleted => 'Viaje completado';

  @override
  String stopProgress(int done, int total) {
    return 'Parada $done de $total';
  }

  @override
  String stopsNotStarted(int total) {
    return '$total paradas · No iniciado';
  }

  @override
  String get pendingAcceptance => 'Pendiente de Aceptación';

  @override
  String get accepted => 'Aceptado';

  @override
  String get enRoutePickup => 'En Camino a Recogida';

  @override
  String get atPickup => 'En Recogida';

  @override
  String get atDelivery => 'En Entrega';

  @override
  String get delivered => 'Entregado';

  @override
  String get completed => 'Completado';

  @override
  String get declined => 'Rechazado';

  @override
  String get acceptLoad => '✓  Aceptar Carga';

  @override
  String get startTrip => '▶  Iniciar Viaje';

  @override
  String get arrivedAtPickup => '📍  Llegué a Recogida';

  @override
  String get loaded => '✅  Cargado';

  @override
  String get arrivedAtDelivery => '📍  Llegué a Entrega';

  @override
  String get deliveredBtn => '✅  Entregado';

  @override
  String get completeTrip => '🏁  Completar Viaje';

  @override
  String get uploadPodToComplete => '🔒  Subir POD para Completar';

  @override
  String get declineLoad => 'Rechazar Carga';

  @override
  String get callPickup => 'Llamar\nRecogida';

  @override
  String get navigate => 'Navegar';

  @override
  String get pod => 'POD';

  @override
  String get uploadPod => 'Subir POD';

  @override
  String get callDelivery => 'Llamar\nEntrega';

  @override
  String get issue => 'Problema';

  @override
  String get loadInformation => 'INFORMACIÓN DE CARGA';

  @override
  String get routeSection => '📍  Ruta';

  @override
  String get loadDetailsSection => '📦  Detalles de Carga';

  @override
  String get origin => 'Origen';

  @override
  String get destination => 'Destino';

  @override
  String get pickup => 'Recogida';

  @override
  String get delivery => 'Entrega';

  @override
  String get stops => 'PARADAS';

  @override
  String get distance => 'Distancia';

  @override
  String get equipment => 'Equipo';

  @override
  String get weight => 'Peso';

  @override
  String get hazardous => 'Peligroso';

  @override
  String get tempControl => 'Control de Temp';

  @override
  String get yes => '⚠️  Sí';

  @override
  String get no => '✓  No';

  @override
  String get yesTemp => '❄️  Sí';

  @override
  String get stopTimeline => 'Paradas';

  @override
  String get allDone => 'Todas completadas ✓';

  @override
  String get done => 'Completado';

  @override
  String get headingHere => '🚛 En camino aquí';

  @override
  String get youAreHere => '📍 Estás aquí';

  @override
  String get upNext => '⏳ Siguiente';

  @override
  String get upcoming => '⏳ Próximo';

  @override
  String get recordedEvents => 'EVENTOS REGISTRADOS';

  @override
  String get arrivedAtStop => 'Llegué a la parada';

  @override
  String get leftStop => 'Salí de la parada';

  @override
  String get podSubmitted => 'POD enviado';

  @override
  String get podReminderBanner =>
      '⚠️  POD requerido — sube antes de completar el viaje';

  @override
  String get reportIssue => 'Reportar Problema';

  @override
  String get dispatcherNotified =>
      'Tu despachador será notificado inmediatamente.';

  @override
  String get delay => 'Retraso';

  @override
  String get breakdown => 'Avería';

  @override
  String get damage => 'Daño';

  @override
  String get dispatcherNotifiedMsg => 'Despachador notificado';

  @override
  String get locationSharing => 'Compartir Ubicación';

  @override
  String get shareMyLocation => 'Compartir mi ubicación';

  @override
  String get updatesAutomatically =>
      'Se actualiza automáticamente mientras conduces.';

  @override
  String get yourDispatcherSees =>
      'Tu despachador ve tu ubicación durante el viaje.';

  @override
  String get locationSharingOn => 'Compartir ubicación activado';

  @override
  String get locationSharingOff => 'Compartir ubicación desactivado';

  @override
  String get save => 'Guardar';

  @override
  String get sharingLocation => 'Compartiendo ubicación';

  @override
  String get locationPaused => 'Ubicación pausada';

  @override
  String get locationOn => 'Ubicación activada';

  @override
  String get locationOff => 'Ubicación desactivada';

  @override
  String get pauseTracking => '¿Pausar Seguimiento?';

  @override
  String get pauseTrackingMsg => 'Los pings de ubicación se detendrán';

  @override
  String get pauseWarning =>
      'El despachador ya no verá tu posición. Toca el badge para reanudar.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get pauseTrackingBtn => 'Pausar Seguimiento';

  @override
  String get confirmAction => 'Confirmar Acción';

  @override
  String get youAreAboutTo => 'Estás a punto de:';

  @override
  String get cannotBeUndone => 'Esto no se puede deshacer.';

  @override
  String get yesConfirm => 'Sí, Confirmar';

  @override
  String get reasonForDeclining => 'Motivo de Rechazo';

  @override
  String get selectReasonBelow => 'Selecciona el motivo abajo';

  @override
  String get vehicleIssue => 'Problema de Vehículo';

  @override
  String get personalEmergency => 'Emergencia Personal';

  @override
  String get routeTooLong => 'Ruta Muy Larga';

  @override
  String get lowRate => 'Tarifa Baja';

  @override
  String get other => 'Otro';

  @override
  String get selectReasonFirst => 'Selecciona un motivo primero.';

  @override
  String get confirmDecline => 'Confirmar Rechazo';

  @override
  String get documents => 'Documentos';

  @override
  String uploadedCount(int count) {
    return '$count / 4 subidos';
  }

  @override
  String get podSigned => 'POD (Firmado)';

  @override
  String get podMandatory => 'Obligatorio antes de completar el viaje';

  @override
  String get eWayBill => 'E-Way Bill';

  @override
  String get invoiceCopy => 'Copia de Factura';

  @override
  String get damagePhoto => 'Foto de Daño';

  @override
  String get optional => 'Opcional';

  @override
  String get required => 'Requerido';

  @override
  String get uploaded => '✓ Subido';

  @override
  String get podUploadedMsg => 'POD subido ✓ — ya puedes completar el viaje';

  @override
  String get uploadPodFirst => 'Por favor sube tu POD primero';

  @override
  String get callPickupContact => 'Contacto de Recogida';

  @override
  String get callDeliveryContact => 'Contacto de Entrega';

  @override
  String get callNow => 'Llamar Ahora';

  @override
  String get callingMsg => 'Llamando a';

  @override
  String get callingDispatcher => 'Llamando al despachador...';

  @override
  String get tripCompletedTitle => '¡Viaje Completado!';

  @override
  String get tripCompletedSubtitle => 'Envío entregado exitosamente.';

  @override
  String get callDispatcher => 'Llamar al Despachador';

  @override
  String get podSubmittedBadge => 'POD enviado';

  @override
  String get tripClosedBadge => 'Viaje cerrado';

  @override
  String get loadDeclined => 'Carga Rechazada';

  @override
  String get youHaveDeclined => 'Has rechazado esta carga.';

  @override
  String get declinedMistake => 'Si fue un error, llama a tu despachador.';

  @override
  String get couldNotUpdate =>
      'No se pudo actualizar el estado. Inténtalo de nuevo.';

  @override
  String get openingMaps => 'Abriendo mapas hacia';

  @override
  String get failedMsg => 'Fallido';
}
