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
  String get forgotPasswordLink => '¿Olvidaste tu contraseña?';

  @override
  String get forgotPasswordTitle => 'Recuperar contraseña';

  @override
  String get forgotPasswordSubtitle =>
      'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña';

  @override
  String get forgotPasswordSend => 'Enviar enlace';

  @override
  String get forgotPasswordSent =>
      'Si existe una cuenta con ese correo, te enviamos un enlace de recuperación';

  @override
  String get resetPasswordTitle => 'Nueva contraseña';

  @override
  String get resetPasswordSubtitle =>
      'Ingresa el token que recibiste y tu nueva contraseña';

  @override
  String get resetTokenLabel => 'Token de recuperación';

  @override
  String get newPasswordLabel => 'Nueva contraseña';

  @override
  String get resetPasswordButton => 'Restablecer contraseña';

  @override
  String get resetPasswordSuccess =>
      'Contraseña restablecida. Inicia sesión con tu nueva clave';

  @override
  String get backToLogin => 'Volver a iniciar sesión';

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
  String get genderLabel => 'Género';

  @override
  String get genderMale => 'Hombre';

  @override
  String get genderFemale => 'Mujer';

  @override
  String get genderRequired => 'Selecciona tu género';

  @override
  String get carpoolCommunityInstitutional =>
      'Tu correo es institucional (UPC): esta ruta solo la verán usuarios con correo @upc.edu.pe.';

  @override
  String get carpoolCommunityGeneral =>
      'Esta ruta la verán los usuarios con correo general (no institucional).';

  @override
  String get noEarnings7Days => 'Aún no tienes ingresos en los últimos 7 días';

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
  String get kycSkipForTesting => 'Saltar verificación (modo prueba)';

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
  String get stepDocuments => 'Documentos de propiedad';

  @override
  String get documentsIntro =>
      'Acredita que el vehículo es tuyo. Estos documentos no se muestran públicamente.';

  @override
  String get docPropertyCardFront => 'Tarjeta de propiedad (frente)';

  @override
  String get docPropertyCardBack => 'Tarjeta de propiedad (reverso)';

  @override
  String get docSoat => 'SOAT vigente';

  @override
  String get documentsRequired =>
      'Sube la tarjeta de propiedad (ambas caras) y el SOAT';

  @override
  String get documentsSaved => 'Documentos guardados';

  @override
  String get ownershipPending => 'Acreditación en revisión';

  @override
  String get ownershipApproved => 'Propiedad acreditada';

  @override
  String get ownershipRejected => 'Acreditación rechazada';

  @override
  String documentsCount(int current, int total) {
    return '$current/$total documentos';
  }

  @override
  String get camera => 'Cámara';

  @override
  String get gallery => 'Galería';

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
  String get institutionalEmailRequired =>
      'El carpooling requiere un correo institucional (@upc.edu.pe). Actualiza tu correo para publicar rutas.';

  @override
  String get capacityFull =>
      'Aforo completo: no quedan asientos disponibles. Libera un cupo antes de aceptar.';

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
  String passengerFallback(String id) {
    return 'Pasajero #$id';
  }

  @override
  String unregisteredSeats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count asientos reservados sin datos del pasajero',
      one: '1 asiento reservado sin datos del pasajero',
    );
    return '$_temp0';
  }

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
  String get withdrawAmount => 'Monto a retirar';

  @override
  String get withdrawDestination => 'Número o cuenta de destino';

  @override
  String get withdrawMethod => 'Método de retiro';

  @override
  String get withdrawConfirm => 'Solicitar retiro';

  @override
  String availableToWithdraw(String amount) {
    return 'Disponible: $amount';
  }

  @override
  String get insufficientBalance => 'El monto supera tu saldo disponible';

  @override
  String get withdrawalsHistory => 'Retiros';

  @override
  String get noWithdrawals => 'Aún no has solicitado retiros';

  @override
  String refundPolicyApplied(String policy, String amount) {
    return 'Reembolso procesado ($policy): $amount';
  }

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String get selectTime => 'Seleccionar hora';

  @override
  String get today => 'Hoy';

  @override
  String get rateUser => 'Calificar usuario';

  @override
  String get rateRenter => 'Calificar arrendatario';

  @override
  String get comment => 'Comentario';

  @override
  String get send => 'Enviar';

  @override
  String get ratingSent => 'Calificación enviada';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get changePasswordSubtitle =>
      'Ingresa tu contraseña actual y elige una nueva';

  @override
  String get currentPassword => 'Contraseña actual';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get confirmNewPassword => 'Confirmar nueva contraseña';

  @override
  String get passwordChanged => 'Contraseña actualizada correctamente';

  @override
  String get emergency => 'Emergencia';

  @override
  String get emergencyButton => 'SOS · Emergencia';

  @override
  String get emergencyTitle => '¿Activar alerta de emergencia?';

  @override
  String get emergencyMessage =>
      'Se enviará una alerta con tu ubicación al equipo de soporte y quedará registrada. Úsalo solo ante una situación real.';

  @override
  String get emergencyConfirm => 'Enviar alerta';

  @override
  String get emergencySent =>
      'Alerta de emergencia enviada. El equipo de soporte fue notificado.';

  @override
  String emergencyDescription(String route) {
    return 'ALERTA DE EMERGENCIA activada por el conductor durante la ruta $route.';
  }

  @override
  String get startPinTitle => 'Validar entrega con PIN';

  @override
  String get startPinSubtitle =>
      'Pide al arrendatario el PIN de 4 dígitos que ve en su app y escríbelo para confirmar la entrega.';

  @override
  String get pinLabel => 'PIN de 4 dígitos';

  @override
  String get invalidPin => 'PIN incorrecto. Verifícalo con el arrendatario.';

  @override
  String get pinValidated => 'PIN validado. Entrega confirmada.';

  @override
  String tripPinShare(String pin) {
    return 'PIN de entrega: $pin. Compártelo con el proveedor al recibir el vehículo.';
  }

  @override
  String get reputationThreshold => 'Umbral de reputación mínima';

  @override
  String get reputationThresholdSubtitle =>
      'Solicitudes de pasajeros por debajo de este umbral requieren tu confirmación manual; por encima se pueden aceptar directo.';

  @override
  String reputationThresholdValue(String value) {
    return 'Reputación mínima: $value';
  }

  @override
  String get reputationThresholdSaved => 'Umbral guardado';

  @override
  String get reputationThresholdOff => 'Sin umbral (aceptar a cualquiera)';

  @override
  String lowReputationWarning(String rating, String threshold) {
    return 'Este pasajero ($rating) está por debajo de tu umbral ($threshold). ¿Aceptar de todos modos?';
  }

  @override
  String get acceptAnyway => 'Aceptar de todos modos';

  @override
  String get settings => 'Configuración';

  @override
  String get deleteAccount => 'Eliminar mi cuenta';

  @override
  String get deleteAccountSubtitle =>
      'Baja voluntaria y eliminación de tus datos';

  @override
  String get deleteAccountWarning =>
      'Esta acción elimina tu cuenta y tus datos de forma permanente. No se puede deshacer. Escribe ELIMINAR para confirmar.';

  @override
  String get deleteConfirmWord => 'ELIMINAR';

  @override
  String get deleteAccountConfirm => 'Eliminar definitivamente';

  @override
  String get deleteAccountTypeHint => 'Escribe ELIMINAR';

  @override
  String get accountDeleted => 'Tu cuenta fue eliminada';

  @override
  String get payoutMethods => 'Métodos de cobro';

  @override
  String get payoutMethodsSubtitle =>
      'Guarda tus cuentas para recibir tus retiros más rápido';

  @override
  String get addPayoutMethod => 'Agregar método de cobro';

  @override
  String get noPayoutMethods => 'Aún no has agregado métodos de cobro';

  @override
  String get payoutMethodSaved => 'Método de cobro guardado';

  @override
  String get payoutAlias => 'Alias (ej. Mi Yape)';

  @override
  String get promotions => 'Promociones';

  @override
  String get promotionsSubtitle =>
      'Crea cupones y ofertas temporales para tus alquileres y rutas';

  @override
  String get noPromotions => 'Aún no has creado promociones';

  @override
  String get addPromotion => 'Nueva promoción';

  @override
  String get editPromotion => 'Editar promoción';

  @override
  String get promoCode => 'Código del cupón';

  @override
  String get promoCodeHint => 'Ej. VERANO20';

  @override
  String get promoTitle => 'Título / descripción';

  @override
  String get promoDiscountType => 'Tipo de descuento';

  @override
  String get promoPercent => 'Porcentaje';

  @override
  String get promoFixed => 'Monto fijo';

  @override
  String get promoValue => 'Valor del descuento';

  @override
  String get promoStart => 'Inicio';

  @override
  String get promoEnd => 'Fin';

  @override
  String get promoMinReputation => 'Reputación mínima (recompensa)';

  @override
  String get promoMinReputationHint =>
      '0 = para todos · mayor = solo usuarios con buena reputación';

  @override
  String get promoSaved => 'Promoción guardada';

  @override
  String get promoDeleted => 'Promoción eliminada';

  @override
  String get promoActive => 'Vigente';

  @override
  String get promoScheduled => 'Programada';

  @override
  String get promoExpired => 'Expirada';

  @override
  String get promoDisabled => 'Desactivada';

  @override
  String promoValidity(String start, String end) {
    return '$start → $end';
  }

  @override
  String promoRewardTag(String value) {
    return 'Recompensa ≥ $value★';
  }

  @override
  String get applyCoupon => 'Aplicar cupón';

  @override
  String get applyCouponSubtitle =>
      'Simula el descuento de un cupón sobre un monto (la misma lógica que verá el arrendatario).';

  @override
  String get couponAmount => 'Monto base (S/)';

  @override
  String get couponReputationOptional => 'Reputación del cliente (opcional)';

  @override
  String get couponApply => 'Aplicar';

  @override
  String couponApplied(String discount, String total) {
    return 'Cupón aplicado: -$discount → total $total';
  }

  @override
  String get couponNotFound => 'No existe un cupón con ese código';

  @override
  String get couponNotStarted => 'El cupón aún no está vigente';

  @override
  String get couponExpired => 'El cupón ya expiró';

  @override
  String get couponDisabled => 'El cupón está desactivado';

  @override
  String get couponReputationTooLow =>
      'El cliente no alcanza la reputación mínima del cupón';

  @override
  String get ok => 'Entendido';

  @override
  String get trustFilterTitle => 'Filtrar por confianza';

  @override
  String get trustFilterOff => 'Todas';

  @override
  String get noRequestsAboveThreshold =>
      'Ninguna solicitud alcanza el umbral de confianza.';

  @override
  String belowThresholdSection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count por debajo del umbral',
      one: '1 por debajo del umbral',
    );
    return '$_temp0';
  }

  @override
  String get repeatWeekly => 'Repetir semanalmente';

  @override
  String get repeatWeeklyHint =>
      'Publica esta misma ruta varias semanas seguidas.';

  @override
  String get weekdaysLabel => 'Días de la semana';

  @override
  String numberOfWeeksValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Durante $count semanas',
      one: 'Durante 1 semana',
    );
    return '$_temp0';
  }

  @override
  String get pickAtLeastOneDay => 'Selecciona al menos un día de la semana.';

  @override
  String recurringRoutesPublished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se publicaron $count rutas',
      one: 'Se publicó 1 ruta',
    );
    return '$_temp0';
  }

  @override
  String get allianceTitle => 'Alianza corporativa';

  @override
  String get allianceIntro =>
      'Postula a tu empresa para movilizar a tus colaboradores con WheelsPe. La revisión es automática e inmediata.';

  @override
  String get allianceCompany => 'Razón social';

  @override
  String get allianceRuc => 'RUC';

  @override
  String get allianceRucInvalid => 'El RUC debe tener 11 dígitos';

  @override
  String get allianceContact => 'Persona de contacto';

  @override
  String get alliancePhone => 'Teléfono de contacto';

  @override
  String get allianceFleetSize => 'Flota o colaboradores a movilizar';

  @override
  String get allianceFleetSizeHint =>
      'Estimado de unidades o personas por movilizar.';

  @override
  String get allianceMessage => 'Mensaje (opcional)';

  @override
  String get allianceSubmit => 'Enviar solicitud';

  @override
  String get allianceHistory => 'Solicitudes enviadas';

  @override
  String get allianceApproved => 'Aprobada';

  @override
  String get allianceUnderReview => 'En revisión';

  @override
  String get allianceApprovedTitle => '¡Alianza aprobada!';

  @override
  String get allianceApprovedBody =>
      'Tu empresa cumple los requisitos. Nuestro equipo comercial se pondrá en contacto para activar el convenio.';

  @override
  String get allianceUnderReviewTitle => 'Solicitud en revisión';

  @override
  String get allianceUnderReviewBody =>
      'Recibimos tu solicitud. Se registró para revisión y te contactaremos si necesitamos más datos.';

  @override
  String get anomalyTitle => 'Monitoreo financiero';

  @override
  String get anomalyAutoReviewed =>
      'Revisado automáticamente. Estas señales se marcaron para tu seguimiento.';

  @override
  String anomalyDetected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movimientos marcados para revisión',
      one: '1 movimiento marcado para revisión',
    );
    return '$_temp0';
  }

  @override
  String get anomalyAmountOutlier => 'Monto inusualmente alto';

  @override
  String get anomalyDuplicateCharge => 'Posible cobro duplicado';

  @override
  String get anomalyRefundSpike => 'Exceso de reembolsos';

  @override
  String anomalyRefundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reembolsos en el histórico',
      one: '1 reembolso en el histórico',
    );
    return '$_temp0';
  }

  @override
  String get reviewMediationTitle => 'Mediación de reseñas';

  @override
  String get reviewMediationIntro =>
      'Disputa una reseña injusta. El sistema resuelve automáticamente: si es un voto bajo, atípico y sin justificación, lo excluye de tu reputación.';

  @override
  String get reviewMediationAdjusted => 'Reputación ajustada';

  @override
  String reviewMediationExcludedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reseñas excluidas por mediación',
      one: '1 reseña excluida por mediación',
    );
    return '$_temp0';
  }

  @override
  String get reviewMediationExcludedBadge =>
      'Excluida por mediación automática';

  @override
  String get reviewDisputeAction => 'Disputar';

  @override
  String get reviewDisputeUpheld =>
      'Disputa aceptada: la reseña se excluyó de tu reputación.';

  @override
  String get reviewDisputeRejected =>
      'La reseña se mantiene: no cumple los criterios de exclusión.';

  @override
  String get reviewDisputeRestore => 'Reincorporar';

  @override
  String get reviewDisputeRestored => 'Reseña reincorporada a tu reputación.';
}
