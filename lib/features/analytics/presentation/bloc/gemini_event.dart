part of 'gemini_bloc.dart';

@immutable
sealed class GeminiEvent {}

/// Event to send a message to the Gemini API
final class SendMessage extends GeminiEvent {
  final String message;

  SendMessage({required this.message});
}
