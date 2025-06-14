import 'package:finasstech/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:finasstech/core/theme/theme.dart';
import 'package:finasstech/core/utils/navbar/curved_nav_bar.dart';
import 'package:finasstech/features/expenses/presentation/bloc/expense_bloc.dart';

import 'package:finasstech/features/analytics/presentation/pages/ai_insights_page.dart';
import 'package:finasstech/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:finasstech/features/auth/presentation/pages/signin_page.dart';
import 'package:finasstech/features/budgeting/presentation/bloc/budget_bloc.dart';
import 'package:finasstech/features/budgeting/presentation/pages/budget_page.dart';
import 'package:finasstech/features/settings/presentaion/pages/settings_page.dart';

import 'package:finasstech/features/dashboard/presentaion/pages/dashboard_page.dart';
import 'package:finasstech/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/notification_service.dart';
import 'features/analytics/presentation/bloc/gemini_bloc.dart';
import 'features/dashboard/presentaion/bloc/dashboard_bloc.dart';
import 'features/expenses/presentation/pages/expense_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<AppUserCubit>()),
        BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
        BlocProvider(create: (_) => serviceLocator<BudgetBloc>()),
        BlocProvider(create: (_) => serviceLocator<ExpenseBloc>()),
        BlocProvider(create: (_) => serviceLocator<DashboardBloc>()),
        BlocProvider(create: (_) => serviceLocator<GeminiBloc>()),
      ],
      child: DevicePreview(enabled: false, builder: (context) => const MyApp()),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentPage = 0;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    // Initialize notification service
    _notificationService.initNotification();
  }

  void updatePage(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Request permissions when the app is built and the context is available
    _notificationService.requestPermissions(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'FinassTech',
      themeMode: ThemeMode.dark,
      //theme: AppTheme.lightThemeMode,
      darkTheme: AppTheme.darkThemeMode,
      home: BlocSelector<AppUserCubit, AppUserState, bool>(
        selector: (state) => state is AppUserAuthenticated,
        builder: (context, isAuthenticated) {
          if (!isAuthenticated) return const SignInPage();

          return CurvedNavBar(
            pages: [
              const ExpensePage(),
              const BudgetPage(),
              const DashboardPage(),
              const AiInsightsPage(),
              const SettingsPage(),
            ],
            onPageChanged: updatePage,
          );
        },
      ),
    );
  }
}
