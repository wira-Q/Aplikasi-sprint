class NotificationModel {
  const NotificationModel({
    required this.idNotification,
    required this.idUser,
    required this.title,
    required this.message,
    required this.isRead,
    this.idApplication,
    this.createdAt,
  });

  final int idNotification;
  final String idUser;
  final int? idApplication;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;

  factory NotificationModel.fromMap(Map<String, dynamic> map) =>
      NotificationModel(
        idNotification: (map['id_notification'] as num).toInt(),
        idUser: map['id_user'] as String,
        idApplication: (map['id_application'] as num?)?.toInt(),
        title: (map['title'] as String?) ?? '',
        message: (map['message'] as String?) ?? '',
        isRead: (map['is_read'] as bool?) ?? false,
        createdAt: map['created_at'] == null
            ? null
            : DateTime.parse(map['created_at'] as String).toLocal(),
      );
}
