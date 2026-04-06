import '../models/message_model.dart';
import '../local/dao/message_dao.dart';
import 'chat_repository_interface.dart';

class ChatRepository implements ChatRepositoryInterface {
  final MessageDao _messageDao;

  ChatRepository({required MessageDao messageDao}) : _messageDao = messageDao;

  @override
  Future<MessageModel> sendMessage({
    required String sessionId,
    required String text,
    required MessageSender sender,
  }) async {
    final message = MessageModel(
      sessionId: sessionId,
      type: MessageType.text,
      sender: sender,
      text: text,
      sentAt: DateTime.now(),
    );
    final id = await _messageDao.insertMessage(message);
    return MessageModel(
      id: id,
      sessionId: message.sessionId,
      type: message.type,
      sender: message.sender,
      text: message.text,
      sentAt: message.sentAt,
    );
  }

  @override
  Future<MessageModel> sendImage({
    required String sessionId,
    required String imagePath,
    required MessageSender sender,
  }) async {
    final message = MessageModel(
      sessionId: sessionId,
      type: MessageType.image,
      sender: sender,
      imagePath: imagePath,
      sentAt: DateTime.now(),
    );
    final id = await _messageDao.insertMessage(message);
    return MessageModel(
      id: id,
      sessionId: message.sessionId,
      type: message.type,
      sender: message.sender,
      imagePath: message.imagePath,
      sentAt: message.sentAt,
    );
  }

  @override
  Future<List<MessageModel>> getMessages(String sessionId) async {
    return await _messageDao.getMessagesBySession(sessionId);
  }

  @override
  Future<void> clearChat(String sessionId) async {
    await _messageDao.clearSession(sessionId);
  }

  /// Generates a bot reply based on user message
  @override
  String generateBotReply(String userMessage) {
    final lower = userMessage.toLowerCase();
    if (lower.contains('hello') || lower.contains('hi') || lower.contains('hey')) {
      return 'Hello! 👋 I\'m NewsBot. Ask me anything about the latest news!';
    } else if (lower.contains('news') || lower.contains('headline')) {
      return '📰 You can browse the latest headlines on the News tab. Tap any article to read more!';
    } else if (lower.contains('help')) {
      return '🤖 I can help you with:\n• Latest news updates\n• Article recommendations\n• App navigation tips\nJust ask!';
    } else if (lower.contains('thank')) {
      return '😊 You\'re welcome! Happy to help. Anything else?';
    } else if (lower.contains('weather')) {
      return '🌤️ I\'m a news bot, so I don\'t have live weather data. Check your local weather app for updates!';
    } else if (lower.contains('sport')) {
      return '⚽ For sports news, browse the top headlines and look for sports categories!';
    } else if (lower.contains('tech') || lower.contains('technology')) {
      return '💻 Technology news is very popular! Check the headlines for the latest tech updates.';
    } else if (lower.contains('bye') || lower.contains('goodbye')) {
      return '👋 Goodbye! Have a great day and stay informed!';
    } else {
      final replies = [
        '🤔 Interesting! You can find related news in the headlines section.',
        '📱 I\'m here to help you stay informed. Browse our top headlines!',
        '🌍 Stay updated with the latest world news in the News tab.',
        '💡 Great topic! Check out our curated news feed for more.',
        '📊 That\'s a trending topic! See what\'s being reported in the headlines.',
      ];
      final index = DateTime.now().millisecond % replies.length;
      return replies[index];
    }
  }
}
