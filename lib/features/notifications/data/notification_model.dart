/// Notificación del backend (`/Notifications`).
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool read;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    this.body = '',
    this.type = '',
    this.read = false,
    this.createdAt,
  });

  NotificationModel copyWith({bool? read}) => NotificationModel(
        id: id,
        title: title,
        body: body,
        type: type,
        read: read ?? this.read,
        createdAt: createdAt,
      );

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id']?.toString() ?? '',
        title: (json['title'] ?? json['subject'] ?? '') as String,
        body: (json['body'] ?? json['message'] ?? json['content'] ?? '')
            as String,
        type: (json['type'] ?? '') as String,
        read: json['read'] == true || json['isRead'] == true,
        createdAt: DateTime.tryParse(
            (json['createdAt'] ?? json['date'] ?? '').toString()),
      );
}
