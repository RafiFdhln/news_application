import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:news_apps/data/models/message_model.dart';
import 'package:news_apps/presentation/controllers/chat_controller.dart';
import '../helpers/fake_repositories.dart';

void main() {
  late FakeChatRepository fakeChat;
  late ChatController chatController;

  setUp(() async {
    Get.testMode = true;
    fakeChat = FakeChatRepository();
    chatController = ChatController(chatRepository: fakeChat);
    await Future.delayed(const Duration(milliseconds: 150));
  });

  tearDown(Get.reset);

  group('ChatController — init', () {
    test('sessionId is non-empty and starts with "session_"', () {
      expect(chatController.sessionId.value, isNotEmpty);
      expect(chatController.sessionId.value, startsWith('session_'));
    });

    test('isBotTyping starts false', () {
      expect(chatController.isBotTyping.value, false);
    });

    test('isLoading is false after onInit completes', () async {
      await Future.delayed(const Duration(milliseconds: 200));
      expect(chatController.isLoading.value, false);
    });

    test('messages observable is a RxList', () {
      expect(chatController.messages, isA<RxList>());
    });

    test('a welcome message is added on first session', () async {
      // fakeChat starts empty, so welcome message should be sent
      expect(fakeChat.stored.any((m) => m.isBot), isTrue);
    });
  });

  group('ChatController — sendTextMessage', () {
    test('ignores blank and whitespace-only input', () async {
      final before = chatController.messages.length;
      await chatController.sendTextMessage('   ');
      expect(chatController.messages.length, before);
    });

    test('adds user message to messages list', () async {
      final before = chatController.messages.length;
      await chatController.sendTextMessage('Hello!');
      final userMsgs = chatController.messages
          .where((m) => m.isUser && m.text == 'Hello!')
          .toList();
      expect(userMsgs, isNotEmpty);
      expect(chatController.messages.length, greaterThan(before));
    });

    test('adds bot reply after user message', () async {
      await chatController.sendTextMessage('Hi there!');
      final botMsgs = chatController.messages.where((m) => m.isBot).toList();
      expect(botMsgs.length, greaterThanOrEqualTo(2)); // welcome + reply
    });

    test('bot reply is persisted in repository', () async {
      await chatController.sendTextMessage('Hi!');
      final botStored = fakeChat.stored.where((m) => m.isBot).toList();
      expect(botStored.length, greaterThanOrEqualTo(2));
    });

    test('isBotTyping is false after send completes', () async {
      await chatController.sendTextMessage('Hello');
      expect(chatController.isBotTyping.value, false);
    });
  });

  group('ChatController — clearChat', () {
    test('clears repository session messages', () async {
      await chatController.sendTextMessage('test 1');
      await chatController.clearChat();
      // After clear, fakeChat.stored should only have the new welcome message
      expect(
        fakeChat.stored.every((m) => m.sessionId == chatController.sessionId.value),
        isTrue,
      );
    });

    test('adds welcome message back after clear', () async {
      await chatController.clearChat();
      final botMsgs = chatController.messages.where((m) => m.isBot).toList();
      expect(botMsgs, isNotEmpty);
    });
  });

  group('ChatController — getImageFile', () {
    test('returns null for non-existent path', () {
      expect(chatController.getImageFile('/non/existent/path.jpg'), isNull);
    });

    test('returns null for empty path', () {
      expect(chatController.getImageFile(''), isNull);
    });
  });

  group('ChatController — hasMessages', () {
    test('returns true when messages list has items', () {
      chatController.messages.add(MessageModel(
        sessionId: 'test',
        type: MessageType.text,
        sender: MessageSender.bot,
        text: 'Hi',
        sentAt: DateTime.now(),
      ));
      expect(chatController.hasMessages, isTrue);
    });

    test('returns false when messages list is empty', () {
      chatController.messages.clear();
      expect(chatController.hasMessages, isFalse);
    });
  });

  group('MessageModel — tests', () {
    test('isUser true for user sender', () {
      final m = MessageModel(
        sessionId: 's',
        type: MessageType.text,
        sender: MessageSender.user,
        sentAt: DateTime.now(),
      );
      expect(m.isUser, isTrue);
      expect(m.isBot, isFalse);
    });

    test('isBot true for bot sender', () {
      final m = MessageModel(
        sessionId: 's',
        type: MessageType.text,
        sender: MessageSender.bot,
        sentAt: DateTime.now(),
      );
      expect(m.isBot, isTrue);
    });

    test('isTextMessage true for text type', () {
      final m = MessageModel(
        sessionId: 's',
        type: MessageType.text,
        sender: MessageSender.user,
        sentAt: DateTime.now(),
      );
      expect(m.isTextMessage, isTrue);
      expect(m.isImageMessage, isFalse);
    });

    test('isImageMessage true for image type', () {
      final m = MessageModel(
        sessionId: 's',
        type: MessageType.image,
        sender: MessageSender.user,
        imagePath: '/img.jpg',
        sentAt: DateTime.now(),
      );
      expect(m.isImageMessage, isTrue);
    });

    test('toMap/fromMap round-trip', () {
      final original = MessageModel(
        sessionId: 'session-1',
        type: MessageType.text,
        sender: MessageSender.user,
        text: 'Hello World',
        sentAt: DateTime(2024, 6, 15, 10, 30),
      );
      final restored = MessageModel.fromMap(original.toMap());

      expect(restored.sessionId, original.sessionId);
      expect(restored.type, original.type);
      expect(restored.sender, original.sender);
      expect(restored.text, original.text);
    });
  });

  group('FakeChatRepository — generateBotReply', () {
    test('returns greeting for "hello"', () {
      expect(fakeChat.generateBotReply('hello'), contains('NewsBot'));
    });

    test('returns greeting for "hi"', () {
      expect(fakeChat.generateBotReply('hi there'), contains('NewsBot'));
    });

    test('returns news tip for "news"', () {
      expect(fakeChat.generateBotReply('show me news'), contains('📰'));
    });

    test('returns help info for "help"', () {
      expect(fakeChat.generateBotReply('help me'), contains('🤖'));
    });

    test('always returns non-empty string', () {
      expect(fakeChat.generateBotReply('xyz random xyz'), isNotEmpty);
    });
  });
}
