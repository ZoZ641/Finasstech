import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

class GeminiService {
  final GenerativeModel _model;

  GeminiService(String apiKey)
    : _model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
      ); // Replace with your actual API key

  /// Checks if the device is connected to the internet
  Future<bool> _hasInternetConnection() async {
    try {
      // Attempt to connect to Google's DNS to check internet
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<String> generateResponse(String prompt) async {
    // First check for internet connectivity
    final hasConnection = await _hasInternetConnection();
    if (!hasConnection) {
      return 'Error: No internet connection. Please check your network settings and try again.';
    }

    try {
      // Generate content using the engineered prompt
      final response = await _model.generateContent([
        Content.text(promtEnginering(prompt)),
      ]);
      // Return the response text or a default message if empty
      return response.text ?? 'No response from Gemini.';
    } catch (e) {
      // Return error message if communication fails
      return 'Error communicating with Gemini: $e';
    }
  }

  String promtEnginering(String prompt) {
    return 'you are an expert in Business finance especial for small and media size business answer the following to someone whose '
        'knowledge in business finance is very limited. the answer should be without any markdowns and one paragraph\n$prompt';
  }
}
