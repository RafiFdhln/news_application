import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/chat_repository_interface.dart';

class ChatController extends GetxController {
  final ChatRepositoryInterface _chatRepository;
  final ImagePicker _imagePicker;
  final Duration _botReplyDelay;

  ChatController({
    required ChatRepositoryInterface chatRepository,
    ImagePicker? imagePicker,
    Duration botReplyDelay = const Duration(milliseconds: 1200),
  })  : _chatRepository = chatRepository,
        _imagePicker = imagePicker ?? ImagePicker(),
        _botReplyDelay = botReplyDelay;

  // Observables
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isBotTyping = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString sessionId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    sessionId.value =
        'session_${DateTime.now().toIso8601String().substring(0, 10)}';
    loadMessages();
  }

  Future<void> loadMessages() async {
    isLoading.value = true;
    try {
      final msgs = await _chatRepository.getMessages(sessionId.value);
      messages.value = msgs;
      if (msgs.isEmpty) {
        await _addBotMessage(
          '👋 Hello! I\'m NewsBot, your personal news assistant!\n\nI can help you navigate the app and answer questions about the news. What would you like to know?',
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      final userMsg = await _chatRepository.sendMessage(
        sessionId: sessionId.value,
        text: text.trim(),
        sender: MessageSender.user,
      );
      messages.add(userMsg);
      isBotTyping.value = true;
      await Future.delayed(const Duration(milliseconds: 1200));
      final reply = _chatRepository.generateBotReply(text.trim());
      await _addBotMessage(reply);
    } catch (e) {
      errorMessage.value = 'Failed to send message. Please try again.';
    } finally {
      isBotTyping.value = false;
    }
  }

  Future<void> sendImageFromGallery() async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
      );
      if (picked == null) return;
      await _sendImageMessage(picked.path);
    } catch (e) {
      errorMessage.value = 'Failed to pick image from gallery.';
    }
  }

  Future<void> sendImageFromCamera() async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
      );
      if (picked == null) return;
      await _sendImageMessage(picked.path);
    } catch (e) {
      errorMessage.value = 'Failed to capture image.';
    }
  }

  Future<void> _sendImageMessage(String imagePath) async {
    try {
      final userMsg = await _chatRepository.sendImage(
        sessionId: sessionId.value,
        imagePath: imagePath,
        sender: MessageSender.user,
      );
      messages.add(userMsg);
      isBotTyping.value = true;
      await Future.delayed(const Duration(milliseconds: 1500));
      await _addBotMessage(
        '📸 Nice image! Images shared in chat are saved locally. '
        'Is there any news topic you\'d like me to help you with?',
      );
    } catch (e) {
      errorMessage.value = 'Failed to send image.';
    } finally {
      isBotTyping.value = false;
    }
  }

  Future<void> _addBotMessage(String text) async {
    final botMsg = await _chatRepository.sendMessage(
      sessionId: sessionId.value,
      text: text,
      sender: MessageSender.bot,
    );
    messages.add(botMsg);
  }

  Future<void> clearChat() async {
    await _chatRepository.clearChat(sessionId.value);
    messages.clear();
    await loadMessages();
  }

  bool get hasMessages => messages.isNotEmpty;

  File? getImageFile(String path) {
    try {
      final file = File(path);
      return file.existsSync() ? file : null;
    } catch (_) {
      return null;
    }
  }

  @override
  void onClose() {
    super.onClose();
    if (kDebugMode) print('ChatController disposed');
  }
}
