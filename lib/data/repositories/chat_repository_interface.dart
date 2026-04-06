import '../models/message_model.dart';

abstract class ChatRepositoryInterface {
  Future<MessageModel> sendMessage({
    required String sessionId,
    required String text,
    required MessageSender sender,
  });
  Future<MessageModel> sendImage({
    required String sessionId,
    required String imagePath,
    required MessageSender sender,
  });
  Future<List<MessageModel>> getMessages(String sessionId);
  Future<void> clearChat(String sessionId);
  String generateBotReply(String userMessage);
}
