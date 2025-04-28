import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final GenerativeModel _model;

  GeminiService(String apiKey)
    : _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);

  Future<String> generateResponse(String prompt) async {
    try {
      final response = await _model.generateContent([
        Content.text(promtEnginering(prompt)),
      ]);
      return response.text ?? 'No response from Gemini.';
    } catch (e) {
      return 'Error communicating with Gemini: $e';
    }
  }

  String promtEnginering(String prompt) {
    return 'you are an expert in Business finance especial for small and media size business answer the following  to someone whose knowledge in business finance is very limited. the answer should be without any markdowns and one paragraph\n$prompt';
  }
}
