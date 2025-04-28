import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_pallete.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: BubbleSpecialThree(
        text: message.text,
        color:
            message.isUser
                ? AppPallete.primaryColor
                : AppPallete.lightInputFieldColor,
        isSender: message.isUser,
        textStyle: TextStyle(
          color: message.isUser ? Colors.white : Colors.black,
          fontSize: 17,
        ),
      ),
    );
  }
}
