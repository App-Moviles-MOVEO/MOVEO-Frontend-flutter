/// Estado de la transacción de cobro.
enum TransactionStatus {
  pending,
  completed,
  refunded;

  String get apiValue => switch (this) {
        TransactionStatus.pending => 'PENDING',
        TransactionStatus.completed => 'COMPLETED',
        TransactionStatus.refunded => 'REFUNDED',
      };

  static TransactionStatus fromString(String? value) =>
      switch (value?.toUpperCase()) {
        'COMPLETED' || 'PAID' || 'SUCCESS' => TransactionStatus.completed,
        'REFUNDED' => TransactionStatus.refunded,
        _ => TransactionStatus.pending,
      };
}

/// Origen del cobro: alquiler de vehículo o carpooling.
enum TransactionType {
  rental,
  carpool,
  other;

  static TransactionType fromString(String? value) =>
      switch (value?.toUpperCase()) {
        'RENTAL' || 'RESERVATION' => TransactionType.rental,
        'CARPOOL' || 'ROUTE' => TransactionType.carpool,
        _ => TransactionType.other,
      };
}

class TransactionModel {
  final String id;
  final TransactionType type;
  final TransactionStatus status;
  final String description;
  final double amount;
  final double platformFee;
  final String payerName;
  final String? payerAvatar;
  final String reference;

  /// Alquiler asociado al cobro; permite pedir el comprobante oficial
  /// (`GET /rentals/{id}/invoice`).
  final String rentalId;
  final DateTime date;

  const TransactionModel({
    required this.id,
    this.type = TransactionType.other,
    this.status = TransactionStatus.pending,
    this.description = '',
    required this.amount,
    this.platformFee = 0,
    this.payerName = '',
    this.payerAvatar,
    this.reference = '',
    this.rentalId = '',
    required this.date,
  });

  double get netAmount => amount - platformFee;

  double get feePercent => amount == 0 ? 0 : platformFee / amount * 100;

  /// Ventana de 7 días para solicitar reembolso de un cobro completado.
  bool get refundable =>
      status == TransactionStatus.completed &&
      DateTime.now().difference(date).inDays <= 7;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final payer = json['payer'];
    String payerName = (json['payerName'] ?? '') as String;
    String? payerAvatar;
    if (payer is Map) {
      payerName = (payer['fullName'] ?? payer['name'] ?? payerName) as String;
      payerAvatar = payer['avatarUrl'] as String?;
    }
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      type: TransactionType.fromString(json['type'] as String?),
      status: TransactionStatus.fromString(json['status'] as String?),
      description: (json['description'] ?? json['concept'] ?? '') as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      platformFee:
          ((json['platformFee'] ?? json['fee']) as num?)?.toDouble() ?? 0,
      payerName: payerName,
      payerAvatar: payerAvatar,
      reference: (json['reference'] ?? json['code'] ?? '') as String,
      rentalId:
          (json['rentalId'] ?? json['reservationId'] ?? '').toString(),
      date: DateTime.tryParse(
            (json['date'] ?? json['createdAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
    );
  }
}

/// Resultado de un reembolso (POST /payments/{id}/refund).
class RefundResult {
  final double refundedAmount;
  final String policy;
  final String status;

  const RefundResult({
    this.refundedAmount = 0,
    this.policy = '',
    this.status = 'refunded',
  });

  factory RefundResult.fromJson(Map<String, dynamic> json) => RefundResult(
        refundedAmount: (json['refundedAmount'] as num?)?.toDouble() ?? 0,
        policy: (json['policy'] ?? '') as String,
        status: (json['status'] ?? 'refunded') as String,
      );
}

/// Saldo de la wallet del proveedor (GET /wallet/{userId}).
class WalletBalance {
  final double balance;
  final double pendingWithdrawals;
  final double totalEarned;

  const WalletBalance({
    this.balance = 0,
    this.pendingWithdrawals = 0,
    this.totalEarned = 0,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) => WalletBalance(
        balance: (json['balance'] as num?)?.toDouble() ?? 0,
        pendingWithdrawals:
            (json['pendingWithdrawals'] as num?)?.toDouble() ?? 0,
        totalEarned: (json['totalEarned'] as num?)?.toDouble() ?? 0,
      );
}

/// Solicitud de retiro (GET /withdrawals/user/{id}).
class WithdrawalModel {
  final String id;
  final double amount;
  final String method;
  final String destination;
  final String status;
  final DateTime date;

  const WithdrawalModel({
    required this.id,
    required this.amount,
    this.method = '',
    this.destination = '',
    this.status = 'pending',
    required this.date,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) =>
      WithdrawalModel(
        id: json['id']?.toString() ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        method: (json['method'] ?? '') as String,
        destination: (json['destination'] ?? '') as String,
        status: (json['status'] ?? 'pending') as String,
        date: DateTime.tryParse(
              (json['createdAt'] ?? json['date'] ?? '').toString(),
            ) ??
            DateTime.now(),
      );
}

/// Comprobante/factura asociada a los cobros del proveedor.
class InvoiceModel {
  final String id;
  final String transactionId;
  final String number;
  final String? pdfUrl;
  final DateTime date;

  const InvoiceModel({
    required this.id,
    this.transactionId = '',
    this.number = '',
    this.pdfUrl,
    required this.date,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => InvoiceModel(
        id: json['id']?.toString() ?? '',
        transactionId: json['transactionId']?.toString() ?? '',
        number: (json['number'] ?? json['code'] ?? '') as String,
        pdfUrl: (json['pdfUrl'] ?? json['url']) as String?,
        date: DateTime.tryParse(
              (json['date'] ?? json['createdAt'] ?? '').toString(),
            ) ??
            DateTime.now(),
      );
}
