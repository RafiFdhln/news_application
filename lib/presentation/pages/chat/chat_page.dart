
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../../data/models/message_model.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = Get.find<ChatController>();
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(auth, chat),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Obx(() {
              if (chat.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.highlight),
                );
              }

              // Auto-scroll on new messages
              _scrollToBottom();

              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount:
                    chat.messages.length + (chat.isBotTyping.value ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == chat.messages.length && chat.isBotTyping.value) {
                    return _BotTypingBubble();
                  }
                  final msg = chat.messages[i];
                  return _MessageBubble(message: msg, chat: chat);
                },
              );
            }),
          ),

          // Input bar
          _buildInputBar(chat),
        ],
      ),
    );
  }

  AppBar _buildAppBar(AuthController auth, ChatController chat) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
      ),
      title: Row(
        children: [
          // Bot avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'NB',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppConstants.botName,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Obx(() => Text(
                    chat.isBotTyping.value ? 'Typing...' : 'Online',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: chat.isBotTyping.value
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                  )),
            ],
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded,
                      color: AppColors.error, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Clear Chat',
                    style: TextStyle(
                      color: AppColors.error,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (val) {
            if (val == 'clear') {
              Get.dialog(
                AlertDialog(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    'Clear Chat',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  content: const Text(
                    'Are you sure you want to clear all messages?',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textHint),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        chat.clearChat();
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildInputBar(ChatController chat) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: Color(0xFF2A2A4A), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Image picker
          _ImagePickerButton(chat: chat),
          const SizedBox(width: 8),

          // Text field
          Expanded(
            child: TextField(
              controller: _textCtrl,
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(
                  color: AppColors.textHint,
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send button
          Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: chat.isBotTyping.value
                      ? null
                      : () {
                          final text = _textCtrl.text.trim();
                          if (text.isNotEmpty) {
                            _textCtrl.clear();
                            chat.sendTextMessage(text);
                            _scrollToBottom();
                          }
                        },
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: chat.isBotTyping.value
                          ? null
                          : AppColors.accentGradient,
                      color: chat.isBotTyping.value
                          ? AppColors.surfaceVariant
                          : null,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      color: chat.isBotTyping.value
                          ? AppColors.textHint
                          : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _ImagePickerButton extends StatelessWidget {
  final ChatController chat;
  const _ImagePickerButton({required this.chat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textHint,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Send Image',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _PickerOption(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        onTap: () {
                          Get.back();
                          chat.sendImageFromGallery();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PickerOption(
                        icon: Icons.camera_alt_rounded,
                        label: 'Camera',
                        onTap: () {
                          Get.back();
                          chat.sendImageFromCamera();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.attach_file_rounded,
          color: AppColors.textSecondary,
          size: 22,
        ),
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.highlight, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final ChatController chat;

  const _MessageBubble({required this.message, required this.chat});

  String _formatTime(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: EdgeInsets.only(
        bottom: 8,
        left: isUser ? 48 : 0,
        right: isUser ? 0 : 48,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _BotAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Bubble
                Container(
                  padding:
                      message.isImageMessage ? EdgeInsets.zero : const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.chatBubbleUser
                        : AppColors.chatBubbleBot,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: Border.all(
                      color: isUser
                          ? const Color(0xFF1A3A6A)
                          : const Color(0xFF2A2A4A),
                      width: 1,
                    ),
                  ),
                  child: message.isImageMessage
                      ? _buildImageContent(message)
                      : Text(
                          message.text ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                // Timestamp
                Text(
                  _formatTime(message.sentAt),
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontFamily: 'Poppins',
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            _UserAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildImageContent(MessageModel message) {
    final file = message.imagePath != null
        ? chat.getImageFile(message.imagePath!)
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(16),
        topRight: const Radius.circular(16),
        bottomLeft: Radius.circular(message.isUser ? 16 : 4),
        bottomRight: Radius.circular(message.isUser ? 4 : 16),
      ),
      child: file != null
          ? Image.file(
              file,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            )
          : Container(
              width: 200,
              height: 200,
              color: AppColors.surface,
              child: const Icon(
                Icons.broken_image_rounded,
                color: AppColors.textHint,
                size: 48,
              ),
            ),
    );
  }
}

class _BotTypingBubble extends StatefulWidget {
  @override
  State<_BotTypingBubble> createState() => _BotTypingBubbleState();
}

class _BotTypingBubbleState extends State<_BotTypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _BotAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.chatBubbleBot,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: const Color(0xFF2A2A4A), width: 1),
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final delay = i * 0.3;
                  final t = (_ctrl.value - delay).clamp(0.0, 1.0);
                  final opacity = (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0.3, 1.0);
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.highlight.withOpacity(opacity),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'NB',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.person_rounded,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}
