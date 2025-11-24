import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart'; // DISABLED - Using ImgBB instead
import 'dart:io';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import 'image_upload_service.dart'; // NEW: Free image hosting service

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instance; // DISABLED

  // Create or get existing chat between mentor and student
  Future<String> createOrGetChat({
    required String mentorId,
    required String studentId,
    required Map<String, String> participantNames,
    required Map<String, String?> participantImages,
  }) async {
    // Check if chat already exists
    final existingChat = await _firestore
        .collection('chats')
        .where('participants', arrayContains: mentorId)
        .get();

    for (var doc in existingChat.docs) {
      final chat = ChatModel.fromMap(doc.data());
      if (chat.participants.contains(studentId)) {
        return chat.chatId;
      }
    }

    // Create new chat
    final chatId = _firestore.collection('chats').doc().id;
    final chat = ChatModel(
      chatId: chatId,
      participants: [mentorId, studentId],
      participantNames: participantNames,
      participantImages: participantImages,
      lastMessageTime: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await _firestore.collection('chats').doc(chatId).set(chat.toMap());
    return chatId;
  }

  // Get chats for user
  Stream<List<ChatModel>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatModel.fromMap(doc.data())).toList());
  }

  // Get messages for a chat
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data()))
            .toList());
  }

  // Send text message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
    List<String>? receiverIds,
  }) async {
    final messageId = _firestore.collection('messages').doc().id;
    final message = MessageModel(
      messageId: messageId,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      timestamp: DateTime.now(),
    );

    // Add message
    await _firestore.collection('messages').doc(messageId).set(message.toMap());

    // Update chat's last message
    await _updateChatLastMessage(chatId, text, senderId, receiverIds ?? []);
  }

  // Send image message
  Future<void> sendImageMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required File imageFile,
    String text = '',
    List<String>? receiverIds,
  }) async {
    // Upload image using free service (ImgBB or Cloudinary)
    final imageUrl =
        await StorageService.uploadImage(imageFile, name: 'chat_$chatId');

    if (imageUrl == null) {
      throw Exception(
          'Failed to upload image. Please configure ImgBB or Cloudinary.');
    }

    final messageId = _firestore.collection('messages').doc().id;
    final message = MessageModel(
      messageId: messageId,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      text: text.isEmpty ? '📷 Image' : text,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
    );

    await _firestore.collection('messages').doc(messageId).set(message.toMap());
    await _updateChatLastMessage(
      chatId,
      text.isEmpty ? '📷 Image' : text,
      senderId,
      receiverIds ?? [],
    );
  }

  // Send file message (for documents, PDFs, etc.)
  // Note: For free tier, we'll store file info and link only
  Future<void> sendFileMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required File file,
    required String fileName,
    String text = '',
    List<String>? receiverIds,
  }) async {
    // For files, we'll upload as image if it's an image, otherwise store metadata only
    String? fileUrl;

    // Check if it's an image file
    final extension = fileName.toLowerCase().split('.').last;
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      fileUrl = await StorageService.uploadImage(file, name: fileName);
    }

    final messageId = _firestore.collection('messages').doc().id;
    final message = MessageModel(
      messageId: messageId,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      text: text.isEmpty ? '📎 $fileName' : text,
      timestamp: DateTime.now(),
      fileUrl: fileUrl,
      fileName: fileName,
    );

    await _firestore.collection('messages').doc(messageId).set(message.toMap());
    await _updateChatLastMessage(
      chatId,
      text.isEmpty ? '📎 File' : text,
      senderId,
      receiverIds ?? [],
    );
  }

  // NOTE: _uploadFile method removed - now using StorageService instead
  // This uses free ImgBB or Cloudinary for image hosting

  // Update chat's last message
  Future<void> _updateChatLastMessage(
    String chatId,
    String lastMessage,
    String senderId,
    List<String> receiverIds,
  ) async {
    Map<String, int> unreadCount = {};
    for (var receiverId in receiverIds) {
      if (receiverId != senderId) {
        unreadCount[receiverId] = FieldValue.increment(1) as int;
      }
    }

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': lastMessage,
      'lastMessageSenderId': senderId,
      'lastMessageTime': Timestamp.fromDate(DateTime.now()),
      if (unreadCount.isNotEmpty) 'unreadCount.$senderId': 0,
    });

    // Increment unread count for receivers
    for (var entry in unreadCount.entries) {
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount.${entry.key}': FieldValue.increment(1),
      });
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    final messages = await _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .where('senderId', isNotEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in messages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();

    // Reset unread count
    await _firestore.collection('chats').doc(chatId).update({
      'unreadCount.$userId': 0,
    });
  }

  // Delete message
  Future<void> deleteMessage(String messageId) async {
    await _firestore.collection('messages').doc(messageId).delete();
  }

  // Delete chat
  Future<void> deleteChat(String chatId) async {
    // Delete all messages in chat
    final messages = await _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .get();

    final batch = _firestore.batch();
    for (var doc in messages.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    // Delete chat
    await _firestore.collection('chats').doc(chatId).delete();
  }

  // Get unread message count for user
  Future<int> getUnreadMessageCount(String userId) async {
    final chats = await _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .get();

    int totalUnread = 0;
    for (var doc in chats.docs) {
      final chat = ChatModel.fromMap(doc.data());
      totalUnread += chat.getUnreadCount(userId);
    }

    return totalUnread;
  }

  // Get unread message count as stream for real-time updates
  Stream<int> getUnreadMessageCountStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      int totalUnread = 0;
      for (var doc in snapshot.docs) {
        final chat = ChatModel.fromMap(doc.data());
        totalUnread += chat.getUnreadCount(userId);
      }
      return totalUnread;
    });
  }
}
