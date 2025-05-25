# Finasstech: AI-Powered Budget Planning Assistant

Finasstech is a mobile application developed to support small and medium-sized enterprises (SMEs) in managing their finances more effectively using Artificial Intelligence and Machine Learning. It was designed as a final year project for the Arab Open University (Egypt) and focuses on simplifying budgeting, improving cash flow forecasting, and enhancing financial planning through automation and intelligent recommendations.

---

## 📌 Problem Overview

Many SME owners lack formal financial training and rely on error-prone manual budgeting methods. Finasstech addresses this by providing a tool that:

- Automates budget generation
- Tracks expenses with real-time feedback
- Offers scenario analysis and smart insights
- Provides proactive financial planning support using AI

---

## 🎯 Objectives

- Enable SMEs to make informed financial decisions
- Eliminate manual financial analysis overhead
- Provide a complete budgeting and forecasting tool via mobile
- Improve financial literacy and long-term planning for non-experts

---

## 👥 Target Audience

- SMEs and startups without dedicated finance teams
- Entrepreneurs looking for simple but powerful budgeting tools
- Businesses aiming to adopt AI in their financial workflow

---

## 📦 Deliverables

- AI-powered budget generation and forecast engine
- Expense tracking with automated usage updates
- AI insights chatbot powered by Gemini
- Scenario planning and what-if analysis
- Interactive financial dashboard with visual analytics

---

## 📱 App Features

### ✅ Implemented
- 🔐 User Authentication (Firebase Auth)
- 💰 Budget Creation & Tracking (Local Storage - Hive)
- 🧾 Expense Recording with Recurrence & Categorization
- 📊 Dashboard with real-time budget usage
- 🤖 AI Insights Chatbot (Gemini API)
- 🔔 Local Notifications for Recurring Expenses

### ⛔ Missing (Due to Time Constraints)
- AI-based Expense Categorization
- Prophet Forecast API Integration
- Cloud backup & multi-device sync

---

## 🧠 AI Components

- **Gemini API** for NLP financial chatbot
- Planned integration of **Prophet** for cash flow forecasting
- Planned use of **ML models** for expense classification

---

## 🛠 Tech Stack

| Layer         | Tools & Libraries                          |
|--------------|---------------------------------------------|
| Frontend     | Flutter, BLoC, Dart, Hive                   |
| Auth         | Firebase Authentication                     |
| AI Services  | Gemini API (Google), Prophet (planned)      |
| Architecture | Clean Architecture + Feature-First          |
| State Mgmt   | BLoC, Cubit                                 |
| Storage      | Hive (local, NoSQL)                         |
| Testing      | `flutter_test`, `integration_test`          |

---

## 🧱 Folder Structure

```
lib/
├── features/
│   ├── auth/
│   ├── budget/
│   ├── expense/
│   ├── dashboard/
│   └── ai_insights/
├── core/
│   ├── error/
│   └── utils/
```

---

## 🔬 Testing Strategy

- ✅ Unit Testing: Use cases, logic, validation
- ✅ Widget Testing: UI components (Forms, Dashboard)
- ✅ Integration Testing: Navigation, state transitions
- ✅ Validation & Verification: Test cases for all business requirements

---

## 🧪 Skills Acquired

- Flutter UI/UX design and implementation
- State management using BLoC and Cubit
- Clean Architecture principles
- Integration of third-party services (Firebase, Gemini)
- Testing strategies using Flutter frameworks
- Prompt engineering and error handling with LLM APIs

---

## 📈 Future Work

- 🔁 Implement AI-driven Expense Categorization
- 📡 Complete Prophet integration for accurate forecasting
- ☁️ Add cloud sync (Firebase Firestore or Supabase)
- 🧾 Export reports (CSV/PDF)
- 🔗 Integrate Open Banking APIs
- 🏭 Industry-specific templates and KPIs

---

## 📚 Academic Information

- **Project Title**: AI-Powered Budget Planning Assistant
- **Student Name**: Zeyad Hassan Amin
- **Student ID**: 21511153
- **Module**: TM471 – Final Year Project
- **University**: Arab Open University – Egypt
- **Supervisor**: Dr. Ibrahim Mohamed El-Hasnony
- **Year**: 2025

---

## 📜 License

This software was developed for academic purposes. See the [LICENSE](LICENSE.txt) file for full terms.

---

## 🙏 Acknowledgments

- Arab Open University
- Google Gemini API
- Flutter Community
- QuickBooks, GeeksforGeeks, and academic papers used in the literature review

