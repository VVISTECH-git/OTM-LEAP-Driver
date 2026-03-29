// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Leap Driver';

  @override
  String get checkSms => 'Verifique seu SMS';

  @override
  String get smsInstruction =>
      'Toque no link de remessa enviado para o seu telefone para abrir sua viagem.';

  @override
  String get openSmsApp => 'Abra o aplicativo de SMS';

  @override
  String get smsTapInstruction =>
      'Toque no link de remessa enviado pelo seu despachante para começar.';

  @override
  String get noLoginRequired =>
      'Sem necessidade de login · Acesso fornecido via link SMS';

  @override
  String get loadingShipment => 'Carregando remessa...';

  @override
  String get unableToLoad => 'Não foi possível carregar';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get noData => 'Sem dados';

  @override
  String get shipment => 'REMESSA';

  @override
  String get notStarted => 'Não iniciado';

  @override
  String get headingToPickup => 'A caminho da coleta';

  @override
  String get inTransit => 'Em trânsito';

  @override
  String get allStopsDone =>
      'Todas as paradas concluídas · Pronto para finalizar';

  @override
  String get tripCompleted => 'Viagem concluída';

  @override
  String stopProgress(int done, int total) {
    return 'Parada $done de $total';
  }

  @override
  String stopsNotStarted(int total) {
    return '$total paradas · Não iniciado';
  }

  @override
  String get pendingAcceptance => 'Aguardando Aceitação';

  @override
  String get accepted => 'Aceito';

  @override
  String get enRoutePickup => 'A Caminho da Coleta';

  @override
  String get atPickup => 'Na Coleta';

  @override
  String get atDelivery => 'Na Entrega';

  @override
  String get delivered => 'Entregue';

  @override
  String get completed => 'Concluído';

  @override
  String get declined => 'Recusado';

  @override
  String get acceptLoad => '✓  Aceitar Carga';

  @override
  String get startTrip => '▶  Iniciar Viagem';

  @override
  String get arrivedAtPickup => '📍  Chegou na Coleta';

  @override
  String get loaded => '✅  Carregado';

  @override
  String get arrivedAtDelivery => '📍  Chegou na Entrega';

  @override
  String get deliveredBtn => '✅  Entregue';

  @override
  String get completeTrip => '🏁  Finalizar Viagem';

  @override
  String get uploadPodToComplete => '🔒  Enviar POD para Finalizar';

  @override
  String get declineLoad => 'Recusar Carga';

  @override
  String get callPickup => 'Ligar\nColeta';

  @override
  String get navigate => 'Navegar';

  @override
  String get pod => 'POD';

  @override
  String get uploadPod => 'Enviar POD';

  @override
  String get callDelivery => 'Ligar\nEntrega';

  @override
  String get issue => 'Problema';

  @override
  String get loadInformation => 'INFORMAÇÕES DA CARGA';

  @override
  String get routeSection => '📍  Rota';

  @override
  String get loadDetailsSection => '📦  Detalhes da Carga';

  @override
  String get origin => 'Origem';

  @override
  String get destination => 'Destino';

  @override
  String get pickup => 'Coleta';

  @override
  String get delivery => 'Entrega';

  @override
  String get stops => 'PARADAS';

  @override
  String get distance => 'Distância';

  @override
  String get equipment => 'Equipamento';

  @override
  String get weight => 'Peso';

  @override
  String get hazardous => 'Perigoso';

  @override
  String get tempControl => 'Controle de Temp';

  @override
  String get yes => '⚠️  Sim';

  @override
  String get no => '✓  Não';

  @override
  String get yesTemp => '❄️  Sim';

  @override
  String get stopTimeline => 'Paradas';

  @override
  String get allDone => 'Todas concluídas ✓';

  @override
  String get done => 'Concluído';

  @override
  String get headingHere => '🚛 A caminho';

  @override
  String get youAreHere => '📍 Você está aqui';

  @override
  String get upNext => '⏳ Próxima';

  @override
  String get upcoming => '⏳ Próxima';

  @override
  String get recordedEvents => 'EVENTOS REGISTRADOS';

  @override
  String get arrivedAtStop => 'Chegou na parada';

  @override
  String get leftStop => 'Saiu da parada';

  @override
  String get podSubmitted => 'POD enviado';

  @override
  String get podReminderBanner =>
      '⚠️  POD obrigatório — envie antes de finalizar a viagem';

  @override
  String get reportIssue => 'Reportar Problema';

  @override
  String get dispatcherNotified =>
      'Seu despachante será notificado imediatamente.';

  @override
  String get delay => 'Atraso';

  @override
  String get breakdown => 'Pane';

  @override
  String get damage => 'Dano';

  @override
  String get dispatcherNotifiedMsg => 'Despachante notificado';

  @override
  String get locationSharing => 'Compartilhamento de Localização';

  @override
  String get shareMyLocation => 'Compartilhar minha localização';

  @override
  String get updatesAutomatically =>
      'Atualiza automaticamente enquanto você dirige.';

  @override
  String get yourDispatcherSees =>
      'Seu despachante vê sua localização durante a viagem.';

  @override
  String get locationSharingOn => 'Compartilhamento de localização ativado';

  @override
  String get locationSharingOff => 'Compartilhamento de localização desativado';

  @override
  String get save => 'Salvar';

  @override
  String get sharingLocation => 'Compartilhando localização';

  @override
  String get locationPaused => 'Localização pausada';

  @override
  String get locationOn => 'Localização ativada';

  @override
  String get locationOff => 'Localização desativada';

  @override
  String get pauseTracking => 'Pausar Rastreamento?';

  @override
  String get pauseTrackingMsg => 'Os pings de localização serão interrompidos';

  @override
  String get pauseWarning =>
      'O despachante não verá mais sua posição. Toque no badge para retomar.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get pauseTrackingBtn => 'Pausar Rastreamento';

  @override
  String get confirmAction => 'Confirmar Ação';

  @override
  String get youAreAboutTo => 'Você está prestes a:';

  @override
  String get cannotBeUndone => 'Isso não pode ser desfeito.';

  @override
  String get yesConfirm => 'Sim, Confirmar';

  @override
  String get reasonForDeclining => 'Motivo da Recusa';

  @override
  String get selectReasonBelow => 'Selecione o motivo abaixo';

  @override
  String get vehicleIssue => 'Problema no Veículo';

  @override
  String get personalEmergency => 'Emergência Pessoal';

  @override
  String get routeTooLong => 'Rota Muito Longa';

  @override
  String get lowRate => 'Valor Baixo';

  @override
  String get other => 'Outro';

  @override
  String get selectReasonFirst => 'Selecione um motivo primeiro.';

  @override
  String get confirmDecline => 'Confirmar Recusa';

  @override
  String get documents => 'Documentos';

  @override
  String uploadedCount(int count) {
    return '$count / 4 enviados';
  }

  @override
  String get podSigned => 'POD (Assinado)';

  @override
  String get podMandatory => 'Obrigatório antes de finalizar a viagem';

  @override
  String get eWayBill => 'E-Way Bill';

  @override
  String get invoiceCopy => 'Cópia da Fatura';

  @override
  String get damagePhoto => 'Foto de Dano';

  @override
  String get optional => 'Opcional';

  @override
  String get required => 'Obrigatório';

  @override
  String get uploaded => '✓ Enviado';

  @override
  String get podUploadedMsg => 'POD enviado ✓ — você pode finalizar a viagem';

  @override
  String get uploadPodFirst => 'Por favor, envie seu POD primeiro';

  @override
  String get callPickupContact => 'Contato de Coleta';

  @override
  String get callDeliveryContact => 'Contato de Entrega';

  @override
  String get callNow => 'Ligar Agora';

  @override
  String get callingMsg => 'Ligando para';

  @override
  String get callingDispatcher => 'Ligando para o despachante...';

  @override
  String get tripCompletedTitle => 'Viagem Concluída!';

  @override
  String get tripCompletedSubtitle => 'Remessa entregue com sucesso.';

  @override
  String get callDispatcher => 'Ligar para Despachante';

  @override
  String get podSubmittedBadge => 'POD enviado';

  @override
  String get tripClosedBadge => 'Viagem encerrada';

  @override
  String get loadDeclined => 'Carga Recusada';

  @override
  String get youHaveDeclined => 'Você recusou esta carga.';

  @override
  String get declinedMistake => 'Se foi um engano, ligue para seu despachante.';

  @override
  String get couldNotUpdate => 'Não foi possível atualizar. Tente novamente.';

  @override
  String get openingMaps => 'Abrindo mapas para';

  @override
  String get failedMsg => 'Falhou';
}
