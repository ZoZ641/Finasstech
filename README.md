# FinassTech

AI-Powered Budget Planning Assistant

FinassTech is a cross-platform Flutter application designed to help users manage their finances efficiently. It leverages AI to provide smart budgeting, expense tracking, and personalized financial insights.

## Features

- **User Authentication:** Secure sign-in and sign-up with Firebase.
- **Budget Management:** Create, edit, and track budgets.
- **Expense Tracking:** Log and categorize expenses.
- **AI Assistant:** Get personalized financial advice powered by Gemini AI.
- **Notifications:** Stay updated with reminders and alerts.
- **Dashboard:** Visualize your financial data with charts and summaries.
- **Dark Mode:** Modern dark theme for comfortable viewing.
- **Cross-Platform:** Runs on Android and iOS.

## Project Structure

```
lib/
  main.dart                # App entry point
  init_dependencies.dart   # Dependency injection and service initialization
  firebase_options.dart    # Firebase configuration
  ...
android/                  # Android native code and config
ios/                      # iOS native code and config
.env                      # Environment variables (API keys, etc.)
pubspec.yaml              # Flutter dependencies and assets
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio or Xcode for mobile development

### Setup

1. **Clone the repository:**

   ```sh
   git clone <your-repo-url>
   cd finasstech
   ```

2. **Install dependencies:**

   ```sh
   flutter pub get
   ```

3. **Configure environment variables:**

   - Create a `.env` file in the project root.
   - Add your API keys and configuration (see `.env.example` if available).

4. **Run the app:**
   ```sh
   flutter run
   ```

## Development

- Android configuration: [android/app/build.gradle.kts](android/app/build.gradle.kts)
- iOS configuration: [ios/Runner/Runner-Bridging-Header.h](ios/Runner/Runner-Bridging-Header.h)
- Main app logic: [lib/main.dart](lib/main.dart)
- Dependency setup: [lib/init_dependencies.dart](lib/init_dependencies.dart)

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

[MIT](LICENSE.txt)
