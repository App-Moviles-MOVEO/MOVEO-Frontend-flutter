/// Endpoints y configuración base de la API real de WheelsPe / MOVEO.
///
/// IMPORTANTE: el backend es **SIN JWT** (stateless por `userId`). El login
/// devuelve el objeto usuario; la "sesión" es guardar ese `id` y mandarlo como
/// `?userId=` / `ownerId=` / `recipientId=` / `payerId=` según el endpoint.
class ApiConstants {
  ApiConstants._();

  /// Base URL. Por defecto apunta al backend local desde el emulador Android
  /// (`10.0.2.2` = `localhost` del host). Sobrescribir al compilar con:
  /// `--dart-define=WHEELSPE_API_URL=http://localhost:8080/api/v1`
  static const String baseUrl = String.fromEnvironment(
    'WHEELSPE_API_URL',
    defaultValue: 'http://10.0.2.2:8080/api/v1',
  );

  // Auth — /auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String changePassword = '/auth/change-password';

  // Usuarios — /users
  static const String users = '/users';
  static String userById(String id) => '/users/$id';

  // Vehículos — /vehicles
  static const String vehicles = '/vehicles';
  static String vehicleById(String id) => '/vehicles/$id';
  static String vehicleAvailability(String id) => '/vehicles/$id/availability';

  // Reservas / Alquileres — /rentals
  static const String rentals = '/rentals';
  static const String rentalsActive = '/rentals/active';
  static String rentalById(String id) => '/rentals/$id';
  static String rentalPay(String id) => '/rentals/$id/pay';
  static String rentalsByUser(String userId) => '/rentals/user/$userId';

  // Carpooling / Rutas — /adventure-routes
  static const String routes = '/adventure-routes';
  static String routeById(String id) => '/adventure-routes/$id';
  static String routeBook(String id) => '/adventure-routes/$id/book';

  // Pagos — /Payments
  static const String payments = '/Payments';
  static String paymentById(String id) => '/Payments/$id';
  static String paymentsByRecipient(String id) => '/Payments/recipient/$id';
  static String paymentsByPayer(String id) => '/Payments/payer/$id';
  static String paymentsByRental(String id) => '/Payments/rental/$id';

  // Reseñas de vehículo — /Reviews · Reseñas entre usuarios — /user-reviews
  static const String reviews = '/Reviews';
  static String reviewsByReviewee(String id) => '/Reviews/reviewee/$id';
  static String reviewsByReviewer(String id) => '/Reviews/reviewer/$id';
  static const String userReviews = '/user-reviews';

  // Notificaciones — /Notifications
  static const String notifications = '/Notifications';
  static String notificationsByUser(String id) => '/Notifications/user/$id';
  static String notificationsUnread(String id) =>
      '/Notifications/user/$id/unread';
  static String notificationById(String id) => '/Notifications/$id';
  static String notificationRead(String id) => '/Notifications/$id/read';
  static String notificationsReadAll(String id) =>
      '/Notifications/user/$id/read-all';

  // Chat 1-a-1 — /messages
  static const String messages = '/messages';
  static String conversations(String userId) =>
      '/messages/conversations/$userId';
  static String messageRead(String id) => '/messages/$id/read';

  // Soporte / Ayuda — /support-tickets
  static const String supportTickets = '/support-tickets';
  static String supportTicketById(String id) => '/support-tickets/$id';
  static String supportTicketsByUser(String id) => '/support-tickets/user/$id';
  static String supportTicketClose(String id) => '/support-tickets/$id/close';
  static String supportTicketMessages(String ticketId) =>
      '/support-tickets/$ticketId/messages';
}
