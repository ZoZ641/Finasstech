import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:finasstech/core/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/gemini_bloc.dart';
import '../widgets/chat_message.dart';
import '../widgets/thinker_indicator.dart';

class AiInsightsPage extends StatefulWidget {
  const AiInsightsPage({super.key});

  @override
  State<AiInsightsPage> createState() => _AiInsightsPageState();
}

class _AiInsightsPageState extends State<AiInsightsPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isThinking = false;

  void _sendMessage() {
    // Get and clean the input message
    final message = _messageController.text.trim();

    // Only proceed if there is actual content to send
    if (message.isNotEmpty) {
      // Add the user message to chat immediately
      setState(() {
        _messages.add(ChatMessage(text: message, isUser: true));
        _messageController.clear();
        _isThinking = true;
      });

      // Dispatch the message to the GeminiBloc for processing
      BlocProvider.of<GeminiBloc>(context).add(SendMessage(message: message));

      // Schedule scrolling to the bottom of the chat after the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Financial Insights')),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<GeminiBloc, GeminiState>(
              listener: (context, state) {
                if (state is GeminiResponse) {
                  setState(() {
                    _isThinking = false;
                    _messages.add(
                      ChatMessage(text: state.message, isUser: false),
                    );
                  });
                  // Scroll to the latest message
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  });
                } else if (state is GeminiError) {
                  setState(() {
                    _isThinking = false;
                    // Remove the last user message if it exists
                    if (_messages.isNotEmpty && _messages.last.isUser) {
                      _messages.removeLast();
                    }
                  });
                  showSnackBar(
                    context,
                    'Error',
                    state.message,
                    ContentType.failure,
                  );
                } else if (state is GeminiLoading) {
                  setState(() {
                    _isThinking = true;
                  });
                }
              },
              builder: (context, state) {
                return ListView(
                  controller: _scrollController,
                  children: [
                    ...List.generate(
                      _messages.length,
                      (index) => ChatBubble(message: _messages[index]),
                    ),
                    if (_isThinking) const ThinkingIndicator(),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask me anything...',
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
