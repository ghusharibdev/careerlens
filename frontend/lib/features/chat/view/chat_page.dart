import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../viewmodel/chat_viewmodel.dart';
import '../model/chat_message.dart';
import '../../../core/theme/app_theme.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _vm = ChatViewModel();
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  final _suggestions = [
    'What are my strongest skills?',
    'What technologies am I experienced with?',
    'How many years of experience do I have?',
    'What projects have I built?',
  ];

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _sending) return;
    _ctrl.clear();
    setState(() => _sending = true);
    await _vm.sendMessage(text.trim(), () => setState(() {}));
    setState(() => _sending = false);
    _scrollToBottom();
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppTheme.accentDim,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: AppTheme.accent, size: 16),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chat with Resume', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                Text('Powered by RAG', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ],
        ),
        actions: [
          if (_vm.messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh_outlined, size: 20),
              onPressed: () => _vm.clearChat(() => setState(() {})),
              tooltip: 'Clear chat',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _vm.messages.isEmpty
                ? _EmptyChat(suggestions: _suggestions, onSuggestion: _send)
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _vm.messages.length,
                    itemBuilder: (context, i) {
                      return _MessageBubble(message: _vm.messages[i])
                          .animate()
                          .fadeIn(duration: 250.ms)
                          .slideY(begin: 0.1);
                    },
                  ),
          ),
          _InputBar(ctrl: _ctrl, sending: _sending, onSend: _send),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSuggestion;
  const _EmptyChat({required this.suggestions, required this.onSuggestion});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 32),
        Center(
          child: Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppTheme.accentDim,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.chat_bubble_outline, color: AppTheme.accent, size: 28),
          ).animate().scale(duration: 400.ms),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'Ask anything about your resume',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'The AI answers from your actual resume\nusing semantic search.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, height: 1.5, fontSize: 13),
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 32),
        const Text(
          'SUGGESTIONS',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 12),
        ...suggestions.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => onSuggestion(e.value),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(e.value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14))),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.textMuted),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: (300 + e.key * 60).ms).slideX(begin: 0.05);
        }),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  bool get _isLoading => message.text == '...' && !message.isUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 28, height: 28,
              margin: const EdgeInsets.only(right: 8, top: 2),
              decoration: BoxDecoration(
                color: AppTheme.accentDim,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: AppTheme.accent, size: 14),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? AppTheme.accent : AppTheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
                border: message.isUser ? null : Border.all(color: AppTheme.border),
              ),
              child: _isLoading
                  ? _TypingIndicator()
                  : Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser ? AppTheme.bg : AppTheme.textPrimary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      final c = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) c.repeat(reverse: true);
      });
      return c;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (_, __) => Container(
            width: 6, height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: AppTheme.textMuted.withOpacity(0.3 + _controllers[i].value * 0.7),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final bool sending;
  final Function(String) onSend;
  const _InputBar({required this.ctrl, required this.sending, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppTheme.bg,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              maxLines: 4,
              minLines: 1,
              onSubmitted: onSend,
              decoration: const InputDecoration(
                hintText: 'Ask something about your resume...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: AppTheme.accent, width: 1.5),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: sending ? null : () => onSend(ctrl.text),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: sending ? AppTheme.border : AppTheme.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: sending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.bg),
                    )
                  : const Icon(Icons.send_rounded, color: AppTheme.bg, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
