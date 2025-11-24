import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isTyping;

  ChatMessage({
    required this.text,
    this.isUser = false,
    DateTime? timestamp,
    this.isTyping = false,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final List<AnimationController> _animationControllers = [];
  bool _isLoading = false;
  final FocusNode _textFieldFocus = FocusNode();

  static const Color primaryTeal = Color(0xFF5F8D8E);
  static const Color lightTeal = Color(0xFF7FA8A9);
  static const Color backgroundGray = Color(0xFFE8EDED);
  static const Color cardWhite = Color(0xFFF5F7F7);
  static const Color textDark = Color(0xFF2C3E50);
  static const Color accentGreen = Color(0xFF7CB342);

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        text:
            "Hi there! 👋 I'm PrepBot, your interview preparation assistant.\n\nTo get started, please tell me:\n• The company name\n• The job role you're applying for\n\nExample: 'Google, Software Engineer'",
      ),
    );
    _addAnimationController();
  }

  void _addAnimationController() {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animationControllers.add(controller);
    controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _textFieldFocus.dispose();
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _handleUserSubmit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _addAnimationController();
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    final botResponseText = await _getGeminiResponse();

    setState(() {
      _isLoading = false;
    });
    await _displayResponseInSections(botResponseText);
  }

  Future<void> _displayResponseInSections(String fullResponse) async {
    final sections = _parseResponseIntoSections(fullResponse);

    for (int i = 0; i < sections.length; i++) {
      setState(() {
        _messages.add(ChatMessage(text: sections[i], isTyping: true));
        _addAnimationController();
      });
      _scrollToBottom();
      await Future.delayed(
        Duration(milliseconds: 800 + (sections[i].length * 2)),
      );

      setState(() {
        _messages[_messages.length - 1] = ChatMessage(text: sections[i]);
      });
      _scrollToBottom();

      if (i < sections.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  List<String> _parseResponseIntoSections(String response) {
    final sections = <String>[];
    final lines = response.split('\n');
    String currentSection = '';

    for (var line in lines) {
      if (line.trim().startsWith('###') ||
          line.trim().startsWith('##') ||
          line.trim().startsWith('**Phase')) {
        if (currentSection.trim().isNotEmpty) {
          sections.add(currentSection.trim());
          currentSection = '';
        }
        currentSection = line + '\n';
      } else if (line.trim() == '---' || line.trim() == '***') {
        if (currentSection.trim().isNotEmpty) {
          sections.add(currentSection.trim());
          currentSection = '';
        }
      } else {
        currentSection += line + '\n';

        if (currentSection.length > 400 && line.trim().isEmpty) {
          sections.add(currentSection.trim());
          currentSection = '';
        }
      }
    }

    if (currentSection.trim().isNotEmpty) {
      sections.add(currentSection.trim());
    }

    if (sections.isEmpty || sections.length == 1) {
      return _splitByParagraphs(response);
    }

    return sections;
  }

  List<String> _splitByParagraphs(String text) {
    final paragraphs = text.split('\n\n');
    final sections = <String>[];
    String currentSection = '';

    for (var para in paragraphs) {
      if (para.trim().isEmpty) continue;

      if (currentSection.length + para.length > 500) {
        if (currentSection.isNotEmpty) {
          sections.add(currentSection.trim());
        }
        currentSection = para;
      } else {
        currentSection += (currentSection.isEmpty ? '' : '\n\n') + para;
      }
    }

    if (currentSection.trim().isNotEmpty) {
      sections.add(currentSection.trim());
    }

    return sections.isEmpty ? [text] : sections;
  }
  Future<String> _getGeminiResponse() async {
    final apiKey = String.fromEnvironment('GEMINI_API_KEY');  // dotenv.env['GEMINI_API_KEY'] ?? '';
    final apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-09-2025:generateContent?key=$apiKey';

    final systemInstruction = {
      "parts": [
        {
          "text": """
          You are a friendly and expert interview preparation assistant named PrepBot. Your goal is to help users prepare for job interviews. 
          When a user provides a company and role for the first time, generate a comprehensive, step-by-step interview preparation plan with clear sections using markdown headers (###).
          Structure your response with clear sections like:
          ### Phase 1: Company Research
          ### Phase 2: Technical Preparation
          ### Phase 3: Behavioral Preparation
          etc.
          
          For follow-up questions, provide helpful advice and continue the conversation naturally.
          Use emojis sparingly to make responses more engaging.
          Keep each section focused and concise for better readability.
          """,
        },
      ],
    };

    final contents = _messages.where((msg) => !msg.isTyping).map((msg) {
      final role = msg.isUser ? "user" : "model";
      return {
        "role": role,
        "parts": [
          {"text": msg.text},
        ],
      };
    }).toList();

    final payload = {
      "contents": contents,
      "systemInstruction": systemInstruction,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
            "I'm not sure how to respond to that. Could you try rephrasing?";
      } else {
        final errorBody = jsonDecode(response.body);
        return "Sorry, I couldn't process that. Error: ${errorBody['error']['message']}";
      }
    } catch (e) {
      return "Sorry, something went wrong. Please check your connection and try again.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        backgroundColor: cardWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.psychology, color: primaryTeal, size: 22),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PrepBot',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                Text(
                  'Interview Assistant',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF7A8A99),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: accentGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 12,
                    color: textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildAnimatedMessage(msg, index);
                    },
                  ),
          ),
          if (_isLoading) _buildLoadingIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.psychology, size: 64, color: primaryTeal),
          ),
          const SizedBox(height: 24),
          const Text(
            'Start Your Interview Prep',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Get personalized preparation plans',
            style: TextStyle(fontSize: 15, color: Color(0xFF7A8A99)),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMessage(ChatMessage msg, int index) {
    if (index >= _animationControllers.length) return Container();

    final animation = CurvedAnimation(
      parent: _animationControllers[index],
      curve: Curves.easeOutCubic,
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(msg.isUser ? 0.2 : -0.2, 0),
          end: Offset.zero,
        ).animate(animation),
        child: _buildMessageBubble(msg),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.isUser;

    final markdownStyleSheet = MarkdownStyleSheet(
      p: TextStyle(
        color: isUser ? Colors.white : textDark,
        fontSize: 15,
        height: 1.4,
        fontWeight: FontWeight.w400,
      ),
      h3: TextStyle(
        color: isUser ? Colors.white : textDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      listBullet: TextStyle(
        color: isUser ? Colors.white : textDark,
        fontSize: 15,
        height: 1.4,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryTeal.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.psychology, color: primaryTeal, size: 20),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? primaryTeal : cardWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: msg.isTyping
                      ? _buildTypingAnimation()
                      : MarkdownBody(
                          data: msg.text,
                          styleSheet: markdownStyleSheet,
                          selectable: true,
                        ),
                ),
                if (!msg.isTyping) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      _formatTime(msg.timestamp),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9BA8B5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFD4DFE0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF6B7D8C),
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingAnimation() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTypingDot(0),
        const SizedBox(width: 4),
        _buildTypingDot(200),
        const SizedBox(width: 4),
        _buildTypingDot(400),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryTeal.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.psychology, color: primaryTeal, size: 20),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(200),
                const SizedBox(width: 4),
                _buildTypingDot(400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -4 * (0.5 - (value - 0.5).abs()) * 2),
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: primaryTeal.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          Future.delayed(Duration(milliseconds: delay), () {
            if (mounted) setState(() {});
          });
        }
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundGray,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: _textFieldFocus.hasFocus
                        ? primaryTeal.withOpacity(0.3)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _textFieldFocus,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null,
                  style: const TextStyle(fontSize: 15, color: textDark),
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(
                      color: Color(0xFF9BA8B5),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 18.0,
                      vertical: 12.0,
                    ),
                  ),
                  onSubmitted: (text) => _handleUserSubmit(),
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            Container(
              decoration: BoxDecoration(
                color: primaryTeal,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryTeal.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleUserSubmit,
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
