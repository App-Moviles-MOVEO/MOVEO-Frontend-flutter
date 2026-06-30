/// Mensaje 1-a-1 (`/messages`).
class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final bool read;
  final DateTime? createdAt;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.content = '',
    this.read = false,
    this.createdAt,
  });

  bool isMine(String userId) => senderId == userId;

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id']?.toString() ?? '',
        senderId: (json['senderId'] ?? json['fromUserId'] ?? '').toString(),
        receiverId:
            (json['receiverId'] ?? json['toUserId'] ?? '').toString(),
        content: (json['content'] ?? json['text'] ?? json['message'] ?? '')
            as String,
        read: json['read'] == true || json['isRead'] == true,
        createdAt: DateTime.tryParse(
            (json['createdAt'] ?? json['sentAt'] ?? '').toString()),
      );
}

/// Resumen de conversación (`/messages/conversations/{userId}`).
class ConversationModel {
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String lastMessage;
  final int unreadCount;
  final DateTime? lastDate;

  const ConversationModel({
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.lastMessage = '',
    this.unreadCount = 0,
    this.lastDate,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    // El "otro usuario" puede venir plano o anidado en "otherUser"/"user".
    final other = json['otherUser'] ?? json['user'];
    String id = (json['otherUserId'] ?? json['userId'] ?? '').toString();
    String name = (json['otherUserName'] ?? json['name'] ?? '') as String;
    String? avatar = (json['otherUserAvatar'] ?? json['avatarUrl']) as String?;
    if (other is Map) {
      id = (other['id'] ?? id).toString();
      name = (other['fullName'] ?? other['name'] ?? name) as String;
      avatar = (other['avatarUrl'] ?? other['avatar'] ?? avatar) as String?;
    }
    return ConversationModel(
      otherUserId: id,
      otherUserName: name.isEmpty ? 'Usuario' : name,
      otherUserAvatar: avatar,
      lastMessage:
          (json['lastMessage'] ?? json['lastMessageContent'] ?? '') as String,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      lastDate: DateTime.tryParse(
          (json['lastMessageDate'] ?? json['updatedAt'] ?? '').toString()),
    );
  }
}
