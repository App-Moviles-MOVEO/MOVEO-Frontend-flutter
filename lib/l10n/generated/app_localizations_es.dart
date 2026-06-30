// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'WheelsPe';

  @override
  String get onboardingTitle1 => 'Monetiza tu vehículo';

  @override
  String get onboardingBody1 =>
      'Publica tu auto y genera ingresos alquilándolo a usuarios verificados.';

  @override
  String get onboardingTitle2 => 'Verifica tu identidad';

  @override
  String get onboardingBody2 =>
      'Sube tu DNI y opera con la confianza de una comunidad verificada.';

  @override
  String get onboardingTitle3 => 'Cobra sin efectivo';

  @override
  String get onboardingBody3 =>
      'Recibe tus pagos directamente en tu wallet digital WheelsPe.';

  @override
  String get onboardingStart => 'Comenzar';

  @override
  String get onboardingSkip => 'Saltar';

  @override
  String get loginTitle => 'Inicia sesión';

  @override
  String get loginSubtitle =>
      'Bienvenido de vuelta, ingresa a tu cuenta de proveedor';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get noAccountQuestion => '¿No tienes cuenta? Regístrate';

  @override
  String get registerTitle => 'Crea tu cuenta';

  @override
  String get registerSubtitle =>
      'Únete como proveedor y empieza a generar ingresos';

  @override
  String get fullNameLabel => 'Nombre completo';

  @override
  String get phoneLabel => 'Teléfono';

  @override
  String get confirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get acceptTerms => 'Acepto los Términos y Condiciones';

  @override
  String get registerButton => 'Registrarme';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get invalidEmail => 'Ingresa un correo válido';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get passwordsDontMatch => 'Las contraseñas no coinciden';

  @override
  String get invalidPhone => 'El teléfono debe tener 9 dígitos';

  @override
  String get requiredField => 'Este campo es obligatorio';

  @override
  String get invalidPlate => 'Formato de placa inválido (ej. ABC-123)';

  @override
  String get mustAcceptTerms => 'Debes aceptar los términos y condiciones';

  @override
  String get kycTitle => 'Verificación de identidad';

  @override
  String get kycIntro => 'Verifica tu identidad para empezar a operar';

  @override
  String get kycUploadFront => 'Subir DNI frontal';

  @override
  String get kycUploadBack => 'Subir DNI posterior';

  @override
  String get kycSubmit => 'Enviar documentos';

  @override
  String get kycReviewTime => 'La verificación toma 24-48 horas';

  @override
  String get kycInReview => 'Tus documentos están en revisión';

  @override
  String get kycRejected => 'Verificación rechazada';

  @override
  String get kycRetry => 'Reintentar';

  @override
  String get kycVerified => 'Identidad Verificada';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String homeGreeting(String name) {
    return 'Hola, $name';
  }

  @override
  String get availableBalance => 'Balance disponible';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get last7Days => 'Ingresos últimos 7 días';

  @override
  String get pendingReservations => 'Reservas pendientes';

  @override
  String get todayRoutes => 'Rutas activas hoy';

  @override
  String get quickActions => 'Accesos rápidos';

  @override
  String get publishVehicle => 'Publicar vehículo';

  @override
  String get publishRoute => 'Publicar ruta';

  @override
  String get viewEarnings => 'Ver cobros';

  @override
  String get reportIncident => 'Reportar incidente';

  @override
  String get confirm => 'Confirmar';

  @override
  String get reject => 'Rechazar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get retryButton => 'Reintentar';

  @override
  String get save => 'Guardar';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get close => 'Cerrar';

  @override
  String get seeAll => 'Ver todas';

  @override
  String get navHome => 'Inicio';

  @override
  String get navFleet => 'Mi flota';

  @override
  String get navRoutes => 'Rutas';

  @override
  String get navProfile => 'Perfil';

  @override
  String get fleetTitle => 'Mis vehículos';

  @override
  String get fleetEmpty => 'Publica tu primer vehículo';

  @override
  String get fleetEmptyBody =>
      'Aún no tienes vehículos publicados. Empieza a generar ingresos hoy.';

  @override
  String get statusAvailable => 'Disponible';

  @override
  String get statusRented => 'Alquilado';

  @override
  String get statusMaintenance => 'Mantenimiento';

  @override
  String get statusScheduled => 'Programada';

  @override
  String get statusInProgress => 'En curso';

  @override
  String get statusCompleted => 'Completada';

  @override
  String get statusCancelled => 'Cancelada';

  @override
  String get statusPending => 'Pendiente';

  @override
  String get statusConfirmed => 'Confirmada';

  @override
  String get statusRefunded => 'Reembolsado';

  @override
  String vehicleStats(int count, String amount) {
    return '$count reservas este mes | $amount generados';
  }

  @override
  String get vehicleDetailTitle => 'Detalle del vehículo';

  @override
  String get pricePerDay => 'Precio por día';

  @override
  String get category => 'Categoría';

  @override
  String get plate => 'Placa';

  @override
  String get year => 'Año';

  @override
  String get location => 'Ubicación';

  @override
  String get description => 'Descripción';

  @override
  String get brand => 'Marca';

  @override
  String get model => 'Modelo';

  @override
  String get markAvailable => 'Marcar disponible';

  @override
  String get markMaintenance => 'Enviar a mantenimiento';

  @override
  String get startDelivery => 'Iniciar entrega';

  @override
  String get registerReturn => 'Registrar devolución';

  @override
  String get photoChecklist => 'Checklist fotográfico';

  @override
  String get reservationsSection => 'Reservas';

  @override
  String get addVehicleTitle => 'Publicar vehículo';

  @override
  String get stepBasicData => 'Datos básicos';

  @override
  String get stepPriceAvailability => 'Precio y disponibilidad';

  @override
  String get stepPhotos => 'Fotos';

  @override
  String get stepConfirmation => 'Confirmación';

  @override
  String get deliveryLocation => 'Ubicación de entrega';

  @override
  String get descriptionHint => 'Describe tu vehículo (máx. 300 caracteres)';

  @override
  String get minPhotosRequired => 'Mínimo 3 fotos requeridas';

  @override
  String photosCount(int current, int max) {
    return '$current/$max fotos';
  }

  @override
  String get publishVehicleButton => 'Publicar vehículo';

  @override
  String get vehiclePublished => '¡Vehículo publicado!';

  @override
  String get next => 'Siguiente';

  @override
  String get back => 'Atrás';

  @override
  String get checklistTitlePre => 'Registro de estado — Pre alquiler';

  @override
  String get checklistTitlePost => 'Registro de estado — Post alquiler';

  @override
  String get checklistSubtitle => 'Toma fotos de todas las partes del vehículo';

  @override
  String checklistProgress(int done, int total) {
    return '$done/$total puntos registrados';
  }

  @override
  String get checklistFinish => 'Finalizar registro';

  @override
  String get checklistSaved => 'Registro guardado correctamente';

  @override
  String get checkFront => 'Frontal';

  @override
  String get checkRightSide => 'Lateral derecho';

  @override
  String get checkLeftSide => 'Lateral izquierdo';

  @override
  String get checkRear => 'Trasero';

  @override
  String get checkDriverInterior => 'Interior conductor';

  @override
  String get checkPassengerInterior => 'Interior pasajero';

  @override
  String get checkDashboard => 'Tablero';

  @override
  String get checkTrunk => 'Maletero';

  @override
  String get checkTires => 'Llantas';

  @override
  String get checkRoof => 'Techo';

  @override
  String get retakePhoto => 'Retomar';

  @override
  String get tabPending => 'Pendientes';

  @override
  String get tabActive => 'Activas';

  @override
  String get tabHistory => 'Historial';

  @override
  String get tabUpcoming => 'Próximas';

  @override
  String get tabInProgress => 'En curso';

  @override
  String get reservationDetailTitle => 'Detalle de reserva';

  @override
  String get renterInfo => 'Información del arrendatario';

  @override
  String get rentalInfo => 'Información del alquiler';

  @override
  String get timeline => 'Línea de tiempo';

  @override
  String totalDays(int days) {
    return '$days días';
  }

  @override
  String get totalAmount => 'Monto total';

  @override
  String get deposit => 'Depósito retenido';

  @override
  String get confirmReservation => 'Confirmar reserva';

  @override
  String get registerVehicleDelivery => 'Registrar entrega del vehículo';

  @override
  String get registerVehicleReturn => 'Registrar devolución';

  @override
  String get viewReceipt => 'Ver comprobante';

  @override
  String get noReservations => 'No hay reservas en esta sección';

  @override
  String get routesTitle => 'Mis rutas';

  @override
  String get routesEmpty => 'Aún no has publicado rutas';

  @override
  String get routesEmptyBody =>
      'Comparte tu ruta y reduce tus costos de viaje.';

  @override
  String seatsOccupied(int taken, int total) {
    return '$taken/$total ocupados';
  }

  @override
  String get pricePerSeat => 'Precio por asiento';

  @override
  String get addRouteTitle => 'Publicar ruta';

  @override
  String get origin => 'Origen';

  @override
  String get destination => 'Destino';

  @override
  String get departureDate => 'Fecha de salida';

  @override
  String get departureTime => 'Hora de salida';

  @override
  String get availableSeats => 'Asientos disponibles';

  @override
  String get upcOnly => 'Solo comunidad UPC';

  @override
  String get womenOnly => 'Solo mujeres';

  @override
  String get additionalNotes => 'Notas adicionales (opcional)';

  @override
  String get publishRouteButton => 'Publicar ruta';

  @override
  String get routePublished => '¡Ruta publicada!';

  @override
  String get routeDetailTitle => 'Detalle de ruta';

  @override
  String get passengers => 'Pasajeros';

  @override
  String get confirmedPassengers => 'Pasajeros confirmados';

  @override
  String get pendingRequests => 'Solicitudes pendientes';

  @override
  String get accept => 'Aceptar';

  @override
  String get startRoute => 'Iniciar ruta';

  @override
  String get finishRoute => 'Finalizar ruta';

  @override
  String get cancelRoute => 'Cancelar ruta';

  @override
  String get routeEarningsSummary => 'Resumen de ingresos';

  @override
  String get ratePassengers => 'Calificar pasajeros';

  @override
  String get noPassengersYet => 'Aún no hay pasajeros en esta ruta';

  @override
  String get transactionsTitle => 'Mis cobros';

  @override
  String get monthTotal => 'Total del mes';

  @override
  String get transactionDetailTitle => 'Detalle de cobro';

  @override
  String get platformFee => 'Comisión plataforma';

  @override
  String get netReceived => 'Neto recibido';

  @override
  String get reference => 'Referencia';

  @override
  String get downloadReceipt => 'Descargar comprobante';

  @override
  String get requestRefund => 'Solicitar reembolso';

  @override
  String get refundProcessed => 'Reembolso procesado';

  @override
  String get noTransactions => 'Aún no tienes cobros registrados';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get verifiedProvider => 'Proveedor Verificado';

  @override
  String get badgesSection => 'Mis badges';

  @override
  String get badgeVerified => 'Verificado';

  @override
  String get badgeVerifiedDesc => 'KYC completado';

  @override
  String get badgePunctual => 'Puntual';

  @override
  String get badgePunctualDesc => 'Más de 90% de entregas a tiempo';

  @override
  String get badgeTopRenter => 'Top Arrendador';

  @override
  String get badgeTopRenterDesc => 'Más de 10 alquileres completados';

  @override
  String get badgeFiveStars => '5 Estrellas';

  @override
  String get badgeFiveStarsDesc => 'Rating promedio mayor o igual a 4.8';

  @override
  String get reputation => 'Reputación';

  @override
  String ratingsCount(int count) {
    return '$count calificaciones';
  }

  @override
  String get latestReviews => 'Últimas reseñas';

  @override
  String get noReviewsYet => 'Aún no tienes reseñas';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get totalRentals => 'Alquileres completados';

  @override
  String get totalRoutes => 'Rutas como conductor';

  @override
  String get totalEarnings => 'Ingresos acumulados';

  @override
  String get wallet => 'Wallet';

  @override
  String get withdrawFunds => 'Retirar fondos';

  @override
  String get withdrawVia => 'Elige tu método de retiro';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get kycStatus => 'Estado KYC';

  @override
  String get language => 'Idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get termsAndConditions => 'Términos y condiciones';

  @override
  String get profileUpdated => 'Perfil actualizado';

  @override
  String get incidentTitle => 'Reportar incidente';

  @override
  String get incidentDescription => 'Descripción del incidente';

  @override
  String get incidentType => 'Tipo de incidente';

  @override
  String get incidentDamage => 'Daño al vehículo';

  @override
  String get incidentAccident => 'Accidente';

  @override
  String get incidentLateness => 'Impuntualidad';

  @override
  String get incidentBehavior => 'Comportamiento';

  @override
  String get incidentOther => 'Otro';

  @override
  String get photoEvidence => 'Evidencia fotográfica';

  @override
  String get relatedReservation => 'Reserva/ruta relacionada';

  @override
  String get submitIncident => 'Enviar reporte';

  @override
  String get incidentReported =>
      'Incidente reportado. El equipo revisará en 24h';

  @override
  String get addPhoto => 'Agregar foto';

  @override
  String get genericError => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get connectionError => 'Error de conexión. Revisa tu internet.';

  @override
  String get sessionExpired => 'Tu sesión expiró. Inicia sesión nuevamente.';

  @override
  String get loading => 'Cargando...';

  @override
  String get newReservationNotificationTitle => 'Nueva reserva pendiente';

  @override
  String get newReservationNotificationBody =>
      'Tienes una nueva solicitud de reserva. Revísala ahora.';

  @override
  String get yape => 'Yape';

  @override
  String get plin => 'Plin';

  @override
  String get card => 'Tarjeta';

  @override
  String get withdrawRequested => 'Solicitud de retiro enviada';

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String get selectTime => 'Seleccionar hora';

  @override
  String get today => 'Hoy';

  @override
  String get rateUser => 'Calificar usuario';

  @override
  String get comment => 'Comentario';

  @override
  String get send => 'Enviar';

  @override
  String get ratingSent => 'Calificación enviada';
}
