import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'WheelsPe'**
  String get appName;

  /// No description provided for @onboardingTitle1.
  ///
  /// In es, this message translates to:
  /// **'Monetiza tu vehículo'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In es, this message translates to:
  /// **'Publica tu auto y genera ingresos alquilándolo a usuarios verificados.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In es, this message translates to:
  /// **'Verifica tu identidad'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In es, this message translates to:
  /// **'Sube tu DNI y opera con la confianza de una comunidad verificada.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In es, this message translates to:
  /// **'Cobra sin efectivo'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In es, this message translates to:
  /// **'Recibe tus pagos directamente en tu wallet digital WheelsPe.'**
  String get onboardingBody3;

  /// No description provided for @onboardingStart.
  ///
  /// In es, this message translates to:
  /// **'Comenzar'**
  String get onboardingStart;

  /// No description provided for @onboardingSkip.
  ///
  /// In es, this message translates to:
  /// **'Saltar'**
  String get onboardingSkip;

  /// No description provided for @loginTitle.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido de vuelta, ingresa a tu cuenta de proveedor'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get loginButton;

  /// No description provided for @noAccountQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? Regístrate'**
  String get noAccountQuestion;

  /// No description provided for @registerTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Únete como proveedor y empieza a generar ingresos'**
  String get registerSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get fullNameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get phoneLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPasswordLabel;

  /// No description provided for @acceptTerms.
  ///
  /// In es, this message translates to:
  /// **'Acepto los Términos y Condiciones'**
  String get acceptTerms;

  /// No description provided for @registerButton.
  ///
  /// In es, this message translates to:
  /// **'Registrarme'**
  String get registerButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta? Inicia sesión'**
  String get alreadyHaveAccount;

  /// No description provided for @invalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo válido'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 8 caracteres'**
  String get passwordTooShort;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordsDontMatch;

  /// No description provided for @invalidPhone.
  ///
  /// In es, this message translates to:
  /// **'El teléfono debe tener 9 dígitos'**
  String get invalidPhone;

  /// No description provided for @requiredField.
  ///
  /// In es, this message translates to:
  /// **'Este campo es obligatorio'**
  String get requiredField;

  /// No description provided for @invalidPlate.
  ///
  /// In es, this message translates to:
  /// **'Formato de placa inválido (ej. ABC-123)'**
  String get invalidPlate;

  /// No description provided for @mustAcceptTerms.
  ///
  /// In es, this message translates to:
  /// **'Debes aceptar los términos y condiciones'**
  String get mustAcceptTerms;

  /// No description provided for @kycTitle.
  ///
  /// In es, this message translates to:
  /// **'Verificación de identidad'**
  String get kycTitle;

  /// No description provided for @kycIntro.
  ///
  /// In es, this message translates to:
  /// **'Verifica tu identidad para empezar a operar'**
  String get kycIntro;

  /// No description provided for @kycUploadFront.
  ///
  /// In es, this message translates to:
  /// **'Subir DNI frontal'**
  String get kycUploadFront;

  /// No description provided for @kycUploadBack.
  ///
  /// In es, this message translates to:
  /// **'Subir DNI posterior'**
  String get kycUploadBack;

  /// No description provided for @kycSubmit.
  ///
  /// In es, this message translates to:
  /// **'Enviar documentos'**
  String get kycSubmit;

  /// No description provided for @kycReviewTime.
  ///
  /// In es, this message translates to:
  /// **'La verificación toma 24-48 horas'**
  String get kycReviewTime;

  /// No description provided for @kycInReview.
  ///
  /// In es, this message translates to:
  /// **'Tus documentos están en revisión'**
  String get kycInReview;

  /// No description provided for @kycRejected.
  ///
  /// In es, this message translates to:
  /// **'Verificación rechazada'**
  String get kycRejected;

  /// No description provided for @kycRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get kycRetry;

  /// No description provided for @kycVerified.
  ///
  /// In es, this message translates to:
  /// **'Identidad Verificada'**
  String get kycVerified;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logout;

  /// No description provided for @homeGreeting.
  ///
  /// In es, this message translates to:
  /// **'Hola, {name}'**
  String homeGreeting(String name);

  /// No description provided for @availableBalance.
  ///
  /// In es, this message translates to:
  /// **'Balance disponible'**
  String get availableBalance;

  /// No description provided for @thisWeek.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In es, this message translates to:
  /// **'Este mes'**
  String get thisMonth;

  /// No description provided for @last7Days.
  ///
  /// In es, this message translates to:
  /// **'Ingresos últimos 7 días'**
  String get last7Days;

  /// No description provided for @pendingReservations.
  ///
  /// In es, this message translates to:
  /// **'Reservas pendientes'**
  String get pendingReservations;

  /// No description provided for @todayRoutes.
  ///
  /// In es, this message translates to:
  /// **'Rutas activas hoy'**
  String get todayRoutes;

  /// No description provided for @quickActions.
  ///
  /// In es, this message translates to:
  /// **'Accesos rápidos'**
  String get quickActions;

  /// No description provided for @publishVehicle.
  ///
  /// In es, this message translates to:
  /// **'Publicar vehículo'**
  String get publishVehicle;

  /// No description provided for @publishRoute.
  ///
  /// In es, this message translates to:
  /// **'Publicar ruta'**
  String get publishRoute;

  /// No description provided for @viewEarnings.
  ///
  /// In es, this message translates to:
  /// **'Ver cobros'**
  String get viewEarnings;

  /// No description provided for @reportIncident.
  ///
  /// In es, this message translates to:
  /// **'Reportar incidente'**
  String get reportIncident;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @reject.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get reject;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @retryButton.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retryButton;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @seeAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todas'**
  String get seeAll;

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// No description provided for @navFleet.
  ///
  /// In es, this message translates to:
  /// **'Mi flota'**
  String get navFleet;

  /// No description provided for @navRoutes.
  ///
  /// In es, this message translates to:
  /// **'Rutas'**
  String get navRoutes;

  /// No description provided for @navProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @fleetTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis vehículos'**
  String get fleetTitle;

  /// No description provided for @fleetEmpty.
  ///
  /// In es, this message translates to:
  /// **'Publica tu primer vehículo'**
  String get fleetEmpty;

  /// No description provided for @fleetEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes vehículos publicados. Empieza a generar ingresos hoy.'**
  String get fleetEmptyBody;

  /// No description provided for @statusAvailable.
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get statusAvailable;

  /// No description provided for @statusRented.
  ///
  /// In es, this message translates to:
  /// **'Alquilado'**
  String get statusRented;

  /// No description provided for @statusMaintenance.
  ///
  /// In es, this message translates to:
  /// **'Mantenimiento'**
  String get statusMaintenance;

  /// No description provided for @statusScheduled.
  ///
  /// In es, this message translates to:
  /// **'Programada'**
  String get statusScheduled;

  /// No description provided for @statusInProgress.
  ///
  /// In es, this message translates to:
  /// **'En curso'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In es, this message translates to:
  /// **'Completada'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelada'**
  String get statusCancelled;

  /// No description provided for @statusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Confirmada'**
  String get statusConfirmed;

  /// No description provided for @statusRefunded.
  ///
  /// In es, this message translates to:
  /// **'Reembolsado'**
  String get statusRefunded;

  /// No description provided for @vehicleStats.
  ///
  /// In es, this message translates to:
  /// **'{count} reservas este mes | {amount} generados'**
  String vehicleStats(int count, String amount);

  /// No description provided for @vehicleDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle del vehículo'**
  String get vehicleDetailTitle;

  /// No description provided for @pricePerDay.
  ///
  /// In es, this message translates to:
  /// **'Precio por día'**
  String get pricePerDay;

  /// No description provided for @category.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get category;

  /// No description provided for @plate.
  ///
  /// In es, this message translates to:
  /// **'Placa'**
  String get plate;

  /// No description provided for @year.
  ///
  /// In es, this message translates to:
  /// **'Año'**
  String get year;

  /// No description provided for @location.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get location;

  /// No description provided for @description.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get description;

  /// No description provided for @brand.
  ///
  /// In es, this message translates to:
  /// **'Marca'**
  String get brand;

  /// No description provided for @model.
  ///
  /// In es, this message translates to:
  /// **'Modelo'**
  String get model;

  /// No description provided for @markAvailable.
  ///
  /// In es, this message translates to:
  /// **'Marcar disponible'**
  String get markAvailable;

  /// No description provided for @markMaintenance.
  ///
  /// In es, this message translates to:
  /// **'Enviar a mantenimiento'**
  String get markMaintenance;

  /// No description provided for @startDelivery.
  ///
  /// In es, this message translates to:
  /// **'Iniciar entrega'**
  String get startDelivery;

  /// No description provided for @registerReturn.
  ///
  /// In es, this message translates to:
  /// **'Registrar devolución'**
  String get registerReturn;

  /// No description provided for @photoChecklist.
  ///
  /// In es, this message translates to:
  /// **'Checklist fotográfico'**
  String get photoChecklist;

  /// No description provided for @reservationsSection.
  ///
  /// In es, this message translates to:
  /// **'Reservas'**
  String get reservationsSection;

  /// No description provided for @addVehicleTitle.
  ///
  /// In es, this message translates to:
  /// **'Publicar vehículo'**
  String get addVehicleTitle;

  /// No description provided for @stepBasicData.
  ///
  /// In es, this message translates to:
  /// **'Datos básicos'**
  String get stepBasicData;

  /// No description provided for @stepPriceAvailability.
  ///
  /// In es, this message translates to:
  /// **'Precio y disponibilidad'**
  String get stepPriceAvailability;

  /// No description provided for @stepPhotos.
  ///
  /// In es, this message translates to:
  /// **'Fotos'**
  String get stepPhotos;

  /// No description provided for @stepConfirmation.
  ///
  /// In es, this message translates to:
  /// **'Confirmación'**
  String get stepConfirmation;

  /// No description provided for @deliveryLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación de entrega'**
  String get deliveryLocation;

  /// No description provided for @descriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Describe tu vehículo (máx. 300 caracteres)'**
  String get descriptionHint;

  /// No description provided for @minPhotosRequired.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 3 fotos requeridas'**
  String get minPhotosRequired;

  /// No description provided for @photosCount.
  ///
  /// In es, this message translates to:
  /// **'{current}/{max} fotos'**
  String photosCount(int current, int max);

  /// No description provided for @publishVehicleButton.
  ///
  /// In es, this message translates to:
  /// **'Publicar vehículo'**
  String get publishVehicleButton;

  /// No description provided for @vehiclePublished.
  ///
  /// In es, this message translates to:
  /// **'¡Vehículo publicado!'**
  String get vehiclePublished;

  /// No description provided for @next.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get next;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get back;

  /// No description provided for @checklistTitlePre.
  ///
  /// In es, this message translates to:
  /// **'Registro de estado — Pre alquiler'**
  String get checklistTitlePre;

  /// No description provided for @checklistTitlePost.
  ///
  /// In es, this message translates to:
  /// **'Registro de estado — Post alquiler'**
  String get checklistTitlePost;

  /// No description provided for @checklistSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Toma fotos de todas las partes del vehículo'**
  String get checklistSubtitle;

  /// No description provided for @checklistProgress.
  ///
  /// In es, this message translates to:
  /// **'{done}/{total} puntos registrados'**
  String checklistProgress(int done, int total);

  /// No description provided for @checklistFinish.
  ///
  /// In es, this message translates to:
  /// **'Finalizar registro'**
  String get checklistFinish;

  /// No description provided for @checklistSaved.
  ///
  /// In es, this message translates to:
  /// **'Registro guardado correctamente'**
  String get checklistSaved;

  /// No description provided for @checkFront.
  ///
  /// In es, this message translates to:
  /// **'Frontal'**
  String get checkFront;

  /// No description provided for @checkRightSide.
  ///
  /// In es, this message translates to:
  /// **'Lateral derecho'**
  String get checkRightSide;

  /// No description provided for @checkLeftSide.
  ///
  /// In es, this message translates to:
  /// **'Lateral izquierdo'**
  String get checkLeftSide;

  /// No description provided for @checkRear.
  ///
  /// In es, this message translates to:
  /// **'Trasero'**
  String get checkRear;

  /// No description provided for @checkDriverInterior.
  ///
  /// In es, this message translates to:
  /// **'Interior conductor'**
  String get checkDriverInterior;

  /// No description provided for @checkPassengerInterior.
  ///
  /// In es, this message translates to:
  /// **'Interior pasajero'**
  String get checkPassengerInterior;

  /// No description provided for @checkDashboard.
  ///
  /// In es, this message translates to:
  /// **'Tablero'**
  String get checkDashboard;

  /// No description provided for @checkTrunk.
  ///
  /// In es, this message translates to:
  /// **'Maletero'**
  String get checkTrunk;

  /// No description provided for @checkTires.
  ///
  /// In es, this message translates to:
  /// **'Llantas'**
  String get checkTires;

  /// No description provided for @checkRoof.
  ///
  /// In es, this message translates to:
  /// **'Techo'**
  String get checkRoof;

  /// No description provided for @retakePhoto.
  ///
  /// In es, this message translates to:
  /// **'Retomar'**
  String get retakePhoto;

  /// No description provided for @tabPending.
  ///
  /// In es, this message translates to:
  /// **'Pendientes'**
  String get tabPending;

  /// No description provided for @tabActive.
  ///
  /// In es, this message translates to:
  /// **'Activas'**
  String get tabActive;

  /// No description provided for @tabHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get tabHistory;

  /// No description provided for @tabUpcoming.
  ///
  /// In es, this message translates to:
  /// **'Próximas'**
  String get tabUpcoming;

  /// No description provided for @tabInProgress.
  ///
  /// In es, this message translates to:
  /// **'En curso'**
  String get tabInProgress;

  /// No description provided for @reservationDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle de reserva'**
  String get reservationDetailTitle;

  /// No description provided for @renterInfo.
  ///
  /// In es, this message translates to:
  /// **'Información del arrendatario'**
  String get renterInfo;

  /// No description provided for @rentalInfo.
  ///
  /// In es, this message translates to:
  /// **'Información del alquiler'**
  String get rentalInfo;

  /// No description provided for @timeline.
  ///
  /// In es, this message translates to:
  /// **'Línea de tiempo'**
  String get timeline;

  /// No description provided for @totalDays.
  ///
  /// In es, this message translates to:
  /// **'{days} días'**
  String totalDays(int days);

  /// No description provided for @totalAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto total'**
  String get totalAmount;

  /// No description provided for @deposit.
  ///
  /// In es, this message translates to:
  /// **'Depósito retenido'**
  String get deposit;

  /// No description provided for @confirmReservation.
  ///
  /// In es, this message translates to:
  /// **'Confirmar reserva'**
  String get confirmReservation;

  /// No description provided for @registerVehicleDelivery.
  ///
  /// In es, this message translates to:
  /// **'Registrar entrega del vehículo'**
  String get registerVehicleDelivery;

  /// No description provided for @registerVehicleReturn.
  ///
  /// In es, this message translates to:
  /// **'Registrar devolución'**
  String get registerVehicleReturn;

  /// No description provided for @viewReceipt.
  ///
  /// In es, this message translates to:
  /// **'Ver comprobante'**
  String get viewReceipt;

  /// No description provided for @noReservations.
  ///
  /// In es, this message translates to:
  /// **'No hay reservas en esta sección'**
  String get noReservations;

  /// No description provided for @routesTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis rutas'**
  String get routesTitle;

  /// No description provided for @routesEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no has publicado rutas'**
  String get routesEmpty;

  /// No description provided for @routesEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Comparte tu ruta y reduce tus costos de viaje.'**
  String get routesEmptyBody;

  /// No description provided for @seatsOccupied.
  ///
  /// In es, this message translates to:
  /// **'{taken}/{total} ocupados'**
  String seatsOccupied(int taken, int total);

  /// No description provided for @pricePerSeat.
  ///
  /// In es, this message translates to:
  /// **'Precio por asiento'**
  String get pricePerSeat;

  /// No description provided for @addRouteTitle.
  ///
  /// In es, this message translates to:
  /// **'Publicar ruta'**
  String get addRouteTitle;

  /// No description provided for @origin.
  ///
  /// In es, this message translates to:
  /// **'Origen'**
  String get origin;

  /// No description provided for @destination.
  ///
  /// In es, this message translates to:
  /// **'Destino'**
  String get destination;

  /// No description provided for @departureDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de salida'**
  String get departureDate;

  /// No description provided for @departureTime.
  ///
  /// In es, this message translates to:
  /// **'Hora de salida'**
  String get departureTime;

  /// No description provided for @availableSeats.
  ///
  /// In es, this message translates to:
  /// **'Asientos disponibles'**
  String get availableSeats;

  /// No description provided for @upcOnly.
  ///
  /// In es, this message translates to:
  /// **'Solo comunidad UPC'**
  String get upcOnly;

  /// No description provided for @womenOnly.
  ///
  /// In es, this message translates to:
  /// **'Solo mujeres'**
  String get womenOnly;

  /// No description provided for @additionalNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas adicionales (opcional)'**
  String get additionalNotes;

  /// No description provided for @publishRouteButton.
  ///
  /// In es, this message translates to:
  /// **'Publicar ruta'**
  String get publishRouteButton;

  /// No description provided for @routePublished.
  ///
  /// In es, this message translates to:
  /// **'¡Ruta publicada!'**
  String get routePublished;

  /// No description provided for @routeDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle de ruta'**
  String get routeDetailTitle;

  /// No description provided for @passengers.
  ///
  /// In es, this message translates to:
  /// **'Pasajeros'**
  String get passengers;

  /// No description provided for @confirmedPassengers.
  ///
  /// In es, this message translates to:
  /// **'Pasajeros confirmados'**
  String get confirmedPassengers;

  /// No description provided for @pendingRequests.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes pendientes'**
  String get pendingRequests;

  /// No description provided for @accept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get accept;

  /// No description provided for @startRoute.
  ///
  /// In es, this message translates to:
  /// **'Iniciar ruta'**
  String get startRoute;

  /// No description provided for @finishRoute.
  ///
  /// In es, this message translates to:
  /// **'Finalizar ruta'**
  String get finishRoute;

  /// No description provided for @cancelRoute.
  ///
  /// In es, this message translates to:
  /// **'Cancelar ruta'**
  String get cancelRoute;

  /// No description provided for @routeEarningsSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen de ingresos'**
  String get routeEarningsSummary;

  /// No description provided for @ratePassengers.
  ///
  /// In es, this message translates to:
  /// **'Calificar pasajeros'**
  String get ratePassengers;

  /// No description provided for @noPassengersYet.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay pasajeros en esta ruta'**
  String get noPassengersYet;

  /// No description provided for @transactionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis cobros'**
  String get transactionsTitle;

  /// No description provided for @monthTotal.
  ///
  /// In es, this message translates to:
  /// **'Total del mes'**
  String get monthTotal;

  /// No description provided for @transactionDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle de cobro'**
  String get transactionDetailTitle;

  /// No description provided for @platformFee.
  ///
  /// In es, this message translates to:
  /// **'Comisión plataforma'**
  String get platformFee;

  /// No description provided for @netReceived.
  ///
  /// In es, this message translates to:
  /// **'Neto recibido'**
  String get netReceived;

  /// No description provided for @reference.
  ///
  /// In es, this message translates to:
  /// **'Referencia'**
  String get reference;

  /// No description provided for @downloadReceipt.
  ///
  /// In es, this message translates to:
  /// **'Descargar comprobante'**
  String get downloadReceipt;

  /// No description provided for @requestRefund.
  ///
  /// In es, this message translates to:
  /// **'Solicitar reembolso'**
  String get requestRefund;

  /// No description provided for @refundProcessed.
  ///
  /// In es, this message translates to:
  /// **'Reembolso procesado'**
  String get refundProcessed;

  /// No description provided for @noTransactions.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes cobros registrados'**
  String get noTransactions;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// No description provided for @verifiedProvider.
  ///
  /// In es, this message translates to:
  /// **'Proveedor Verificado'**
  String get verifiedProvider;

  /// No description provided for @badgesSection.
  ///
  /// In es, this message translates to:
  /// **'Mis badges'**
  String get badgesSection;

  /// No description provided for @badgeVerified.
  ///
  /// In es, this message translates to:
  /// **'Verificado'**
  String get badgeVerified;

  /// No description provided for @badgeVerifiedDesc.
  ///
  /// In es, this message translates to:
  /// **'KYC completado'**
  String get badgeVerifiedDesc;

  /// No description provided for @badgePunctual.
  ///
  /// In es, this message translates to:
  /// **'Puntual'**
  String get badgePunctual;

  /// No description provided for @badgePunctualDesc.
  ///
  /// In es, this message translates to:
  /// **'Más de 90% de entregas a tiempo'**
  String get badgePunctualDesc;

  /// No description provided for @badgeTopRenter.
  ///
  /// In es, this message translates to:
  /// **'Top Arrendador'**
  String get badgeTopRenter;

  /// No description provided for @badgeTopRenterDesc.
  ///
  /// In es, this message translates to:
  /// **'Más de 10 alquileres completados'**
  String get badgeTopRenterDesc;

  /// No description provided for @badgeFiveStars.
  ///
  /// In es, this message translates to:
  /// **'5 Estrellas'**
  String get badgeFiveStars;

  /// No description provided for @badgeFiveStarsDesc.
  ///
  /// In es, this message translates to:
  /// **'Rating promedio mayor o igual a 4.8'**
  String get badgeFiveStarsDesc;

  /// No description provided for @reputation.
  ///
  /// In es, this message translates to:
  /// **'Reputación'**
  String get reputation;

  /// No description provided for @ratingsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} calificaciones'**
  String ratingsCount(int count);

  /// No description provided for @latestReviews.
  ///
  /// In es, this message translates to:
  /// **'Últimas reseñas'**
  String get latestReviews;

  /// No description provided for @noReviewsYet.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes reseñas'**
  String get noReviewsYet;

  /// No description provided for @statistics.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get statistics;

  /// No description provided for @totalRentals.
  ///
  /// In es, this message translates to:
  /// **'Alquileres completados'**
  String get totalRentals;

  /// No description provided for @totalRoutes.
  ///
  /// In es, this message translates to:
  /// **'Rutas como conductor'**
  String get totalRoutes;

  /// No description provided for @totalEarnings.
  ///
  /// In es, this message translates to:
  /// **'Ingresos acumulados'**
  String get totalEarnings;

  /// No description provided for @wallet.
  ///
  /// In es, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @withdrawFunds.
  ///
  /// In es, this message translates to:
  /// **'Retirar fondos'**
  String get withdrawFunds;

  /// No description provided for @withdrawVia.
  ///
  /// In es, this message translates to:
  /// **'Elige tu método de retiro'**
  String get withdrawVia;

  /// No description provided for @editProfile.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get editProfile;

  /// No description provided for @kycStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado KYC'**
  String get kycStatus;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @termsAndConditions.
  ///
  /// In es, this message translates to:
  /// **'Términos y condiciones'**
  String get termsAndConditions;

  /// No description provided for @profileUpdated.
  ///
  /// In es, this message translates to:
  /// **'Perfil actualizado'**
  String get profileUpdated;

  /// No description provided for @incidentTitle.
  ///
  /// In es, this message translates to:
  /// **'Reportar incidente'**
  String get incidentTitle;

  /// No description provided for @incidentDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción del incidente'**
  String get incidentDescription;

  /// No description provided for @incidentType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de incidente'**
  String get incidentType;

  /// No description provided for @incidentDamage.
  ///
  /// In es, this message translates to:
  /// **'Daño al vehículo'**
  String get incidentDamage;

  /// No description provided for @incidentAccident.
  ///
  /// In es, this message translates to:
  /// **'Accidente'**
  String get incidentAccident;

  /// No description provided for @incidentLateness.
  ///
  /// In es, this message translates to:
  /// **'Impuntualidad'**
  String get incidentLateness;

  /// No description provided for @incidentBehavior.
  ///
  /// In es, this message translates to:
  /// **'Comportamiento'**
  String get incidentBehavior;

  /// No description provided for @incidentOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get incidentOther;

  /// No description provided for @photoEvidence.
  ///
  /// In es, this message translates to:
  /// **'Evidencia fotográfica'**
  String get photoEvidence;

  /// No description provided for @relatedReservation.
  ///
  /// In es, this message translates to:
  /// **'Reserva/ruta relacionada'**
  String get relatedReservation;

  /// No description provided for @submitIncident.
  ///
  /// In es, this message translates to:
  /// **'Enviar reporte'**
  String get submitIncident;

  /// No description provided for @incidentReported.
  ///
  /// In es, this message translates to:
  /// **'Incidente reportado. El equipo revisará en 24h'**
  String get incidentReported;

  /// No description provided for @addPhoto.
  ///
  /// In es, this message translates to:
  /// **'Agregar foto'**
  String get addPhoto;

  /// No description provided for @genericError.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal. Inténtalo de nuevo.'**
  String get genericError;

  /// No description provided for @connectionError.
  ///
  /// In es, this message translates to:
  /// **'Error de conexión. Revisa tu internet.'**
  String get connectionError;

  /// No description provided for @sessionExpired.
  ///
  /// In es, this message translates to:
  /// **'Tu sesión expiró. Inicia sesión nuevamente.'**
  String get sessionExpired;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @newReservationNotificationTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva reserva pendiente'**
  String get newReservationNotificationTitle;

  /// No description provided for @newReservationNotificationBody.
  ///
  /// In es, this message translates to:
  /// **'Tienes una nueva solicitud de reserva. Revísala ahora.'**
  String get newReservationNotificationBody;

  /// No description provided for @yape.
  ///
  /// In es, this message translates to:
  /// **'Yape'**
  String get yape;

  /// No description provided for @plin.
  ///
  /// In es, this message translates to:
  /// **'Plin'**
  String get plin;

  /// No description provided for @card.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta'**
  String get card;

  /// No description provided for @withdrawRequested.
  ///
  /// In es, this message translates to:
  /// **'Solicitud de retiro enviada'**
  String get withdrawRequested;

  /// No description provided for @selectDate.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar fecha'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar hora'**
  String get selectTime;

  /// No description provided for @today.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get today;

  /// No description provided for @rateUser.
  ///
  /// In es, this message translates to:
  /// **'Calificar usuario'**
  String get rateUser;

  /// No description provided for @comment.
  ///
  /// In es, this message translates to:
  /// **'Comentario'**
  String get comment;

  /// No description provided for @send.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get send;

  /// No description provided for @ratingSent.
  ///
  /// In es, this message translates to:
  /// **'Calificación enviada'**
  String get ratingSent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
