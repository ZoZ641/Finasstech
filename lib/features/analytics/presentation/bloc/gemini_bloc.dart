import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../core/services/gemini_service.dart';

part 'gemini_event.dart';
part 'gemini_state.dart';

/// A BLoC (Business Logic Component) that handles interactions with the Gemini AI service.
/// This bloc manages the state of Gemini API interactions and processes user messages.
class GeminiBloc extends Bloc<GeminiEvent, GeminiState> {
  /// The Gemini service instance used for making API calls
  final GeminiService _geminiService;

  /// Creates a new instance of [GeminiBloc]
  ///
  /// [geminiService] - The service used to communicate with the Gemini API
  GeminiBloc(this._geminiService) : super(GeminiInitial()) {
    // Register the event handler for SendMessage events
    on<SendMessage>(_onSendMessage);
  }

  /// Handles the SendMessage event by:
  /// 1. Emitting a loading state
  /// 2. Making an API call to Gemini service
  /// 3. Emitting either an error or success state based on the response
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<GeminiState> emit,
  ) async {
    // Indicate that the request is in progress
    emit(GeminiLoading());

    // Get response from Gemini service
    final response = await _geminiService.generateResponse(event.message);

    // Handle error response
    if (response.startsWith('Error')) {
      emit(GeminiError(message: response));
    }
    // Handle successful response
    else {
      emit(GeminiResponse(message: response));
    }
  }
}
