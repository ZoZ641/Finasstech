part of 'gemini_bloc.dart';

@immutable
sealed class GeminiState {}

/// Initial state of the Gemini interaction
final class GeminiInitial extends GeminiState {}

/// State indicating that the Gemini API request is in progress
final class GeminiLoading extends GeminiState {}

/// State containing the successful response from the Gemini API
final class GeminiResponse extends GeminiState {
  final String message;

  GeminiResponse({required this.message});
}

/// State indicating an error occurred during the Gemini API interaction
final class GeminiError extends GeminiState {
  final String message;

  GeminiError({required this.message});
}
