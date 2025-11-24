import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<ChatModel> _chats = [];
  List<MessageModel> _currentChatMessages = [];
  String? _currentChatId;
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;

  List<ChatModel> get chats => _chats;
  List<MessageModel> get currentChatMessages => _currentChatMessages;
  String? get currentChatId => _currentChatId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;

  // Load user chats
  void loadUserChats(String userId) {
    _chatService.getUserChats(userId).listen(
      (chats) {
        _chats = chats;
        _updateUnreadCount(userId);
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  // Update unread count
  void _updateUnreadCount(String userId) {
    int total = 0;
    for (var chat in _chats) {
      total += chat.getUnreadCount(userId);
    }
    _unreadCount = total;
  }

  // Load chat messages
  void loadChatMessages(String chatId) {
    _currentChatId = chatId;
    _chatService.getChatMessages(chatId).listen(
      (messages) {
        _currentChatMessages = messages;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  // Create or get chat
  Future<String?> createOrGetChat({
    required String mentorId,
    required String studentId,
    required Map<String, String> participantNames,
    required Map<String, String?> participantImages,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final chatId = await _chatService.createOrGetChat(
        mentorId: mentorId,
        studentId: studentId,
        participantNames: participantNames,
        participantImages: participantImages,
      );

      _isLoading = false;
      notifyListeners();
      return chatId;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Send message
  Future<bool> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
    List<String>? receiverIds,
  }) async {
    try {
      await _chatService.sendMessage(
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        text: text,
        receiverIds: receiverIds,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      await _chatService.markMessagesAsRead(chatId, userId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Delete chat
  Future<bool> deleteChat(String chatId) async {
    try {
      await _chatService.deleteChat(chatId);
      _chats.removeWhere((chat) => chat.chatId == chatId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear current chat
  void clearCurrentChat() {
    _currentChatId = null;
    _currentChatMessages = [];
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
