import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../model/chat_message.dart';

class ChatViewModel {
  final List<ChatMessage> messages = [];
  final String conversationId = const Uuid().v4();
  final _uuid = const Uuid();

  Future<void> sendMessage(String text, VoidCallback onUpdate) async {
    // Add user message
    messages.add(ChatMessage(
      id: _uuid.v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    // Add loading placeholder
    final loadingId = _uuid.v4();
    messages.add(ChatMessage(
      id: loadingId,
      text: '...',
      isUser: false,
      timestamp: DateTime.now(),
    ));
    onUpdate();

    try {
      final response = await ApiClient().dio.post(
        AppConstants.chatEndpoint,
        data: {
          'question': text,
          'conversationId': conversationId,
        },
      );

      final reply = response.data['answer'] as String;
      final idx = messages.indexWhere((m) => m.id == loadingId);
      if (idx != -1) {
        messages[idx] = ChatMessage(
          id: loadingId,
          text: reply,
          isUser: false,
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      final idx = messages.indexWhere((m) => m.id == loadingId);
      if (idx != -1) {
        messages[idx] = ChatMessage(
          id: loadingId,
          text: 'Something went wrong. Please try again.',
          isUser: false,
          timestamp: DateTime.now(),
        );
      }
    }

    onUpdate();
  }

  void clearChat(VoidCallback onUpdate) {
    messages.clear();
    onUpdate();
  }
}
