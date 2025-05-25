part of 'gemini_bloc.dart';

@immutable
sealed class GeminiEvent {}

/// Event to send a message to the Gemini API
final class SendMessage extends GeminiEvent {
  final String message;

  /// Creates a new [SendMessage] event with the specified message
  ///
  /// [message] - The message to be sent to the Gemini API
  SendMessage({required this.message});
}
