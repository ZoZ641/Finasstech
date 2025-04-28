import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../core/services/gemini_service.dart';

part 'gemini_event.dart';
part 'gemini_state.dart';

class GeminiBloc extends Bloc<GeminiEvent, GeminiState> {
  final GeminiService _geminiService;

  GeminiBloc(this._geminiService) : super(GeminiInitial()) {
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<GeminiState> emit,
  ) async {
    emit(GeminiLoading());
    final response = await _geminiService.generateResponse(event.message);
    if (response.startsWith('Error')) {
      emit(GeminiError(message: response));
    } else {
      emit(GeminiResponse(message: response));
    }
  }
}
