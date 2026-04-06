enum MessageType { text, image }

enum MessageSender { user, bot }

class MessageModel {
  final int? id;
  final String sessionId;
  final MessageType type;
  final MessageSender sender;
  final String? text;
  final String? imagePath;
  final DateTime sentAt;
  final bool isSynced;

  MessageModel({
    this.id,
    required this.sessionId,
    required this.type,
    required this.sender,
    this.text,
    this.imagePath,
    required this.sentAt,
    this.isSynced = false,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as int?,
      sessionId: map['sessionId'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
      sender: MessageSender.values.firstWhere(
        (e) => e.name == map['sender'],
        orElse: () => MessageSender.user,
      ),
      text: map['text'] as String?,
      imagePath: map['imagePath'] as String?,
      sentAt: DateTime.fromMillisecondsSinceEpoch(map['sentAt'] as int),
      isSynced: (map['isSynced'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'sessionId': sessionId,
      'type': type.name,
      'sender': sender.name,
      'text': text,
      'imagePath': imagePath,
      'sentAt': sentAt.millisecondsSinceEpoch,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  bool get isUser => sender == MessageSender.user;
  bool get isBot => sender == MessageSender.bot;
  bool get isTextMessage => type == MessageType.text;
  bool get isImageMessage => type == MessageType.image;

  @override
  String toString() =>
      'MessageModel(id: $id, sender: ${sender.name}, text: $text)';
}
