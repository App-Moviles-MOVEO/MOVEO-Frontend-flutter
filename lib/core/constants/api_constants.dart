/// Endpoints y configuración base de la API de WheelsPe.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'WHEELSPE_API_URL',
    defaultValue: 'https://wheelspe-backend.azurewebsites.net/api/v1',
  );

  // Auth & KYC
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String kycUpload = '/auth/kyc/upload';
  static const String kycStatus = '/auth/kyc/status';

  // Usuarios
  static String userById(String id) => '/users/$id';
  static const String users = '/users';
  static const String rateUser = '/ratings/user';

  // Vehículos
  static const String vehicles = '/vehicles';
  static String vehicleById(String id) => '/vehicles/$id';
  static String vehicleStatus(String id) => '/vehicles/$id/status';

  // Reservas
  static String reservationsByVehicle(String vehicleId) =>
      '/reservations/vehicle/$vehicleId';
  static String reservationById(String id) => '/reservations/$id';
  static String reservationConfirm(String id) => '/reservations/$id/confirm';
  static String reservationStart(String id) => '/reservations/$id/start';
  static String reservationComplete(String id) => '/reservations/$id/complete';
  static String reservationCancel(String id) => '/reservations/$id/cancel';

  // Rutas carpooling
  static String routesByDriver(String driverId) => '/routes/driver/$driverId';
  static String routeById(String id) => '/routes/$id';
  static const String routes = '/routes';
  static String routePassengers(String id) => '/routes/$id/passengers';
  static String routePassengerById(String id, String pid) =>
      '/routes/$id/passengers/$pid';
  static String routeComplete(String id) => '/routes/$id/complete';
  static String routeCancel(String id) => '/routes/$id/cancel';

  // Transacciones
  static String transactionsByPayee(String userId) =>
      '/transactions/payee/$userId';
  static String transactionById(String id) => '/transactions/$id';
  static String invoicesByUser(String uid) => '/transactions/invoices/user/$uid';
  static String transactionRefund(String id) => '/transactions/$id/refund';

  // Incidentes
  static const String incidents = '/incidents';
  static String incidentsByUser(String uid) => '/incidents/user/$uid';
  static String incidentById(String id) => '/incidents/$id';
}
