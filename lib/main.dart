import 'package:finasstech/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:finasstech/core/theme/theme.dart';
import 'package:finasstech/core/utils/navbar/curved_nav_bar.dart';

import 'package:finasstech/features/analytics/presentation/pages/ai_insights_page.dart';
import 'package:finasstech/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:finasstech/features/auth/presentation/pages/signin_page.dart';
import 'package:finasstech/features/budgeting/presentation/bloc/budget_bloc.dart';
import 'package:finasstech/features/budgeting/presentation/pages/budget_page.dart';

import 'package:finasstech/features/dashboard/presentaion/pages/dashboard_page.dart';
import 'package:finasstech/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/common/widgets/loader.dart';
import 'core/services/notification_service.dart';
import 'core/utils/show_snackbar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'features/dashboard/presentaion/bloc/dashboard_bloc.dart';
import 'features/expenses/presentation/bloc/expense_bloc.dart';
import 'features/expenses/presentation/pages/expense_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  await initDependencies();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<AppUserCubit>()),
        BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
        BlocProvider(create: (_) => serviceLocator<BudgetBloc>()),
        BlocProvider(create: (_) => serviceLocator<ExpenseBloc>()),
        BlocProvider(create: (_) => serviceLocator<DashboardBloc>()),
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

  void updatePage(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'FinassTech',
      theme: AppTheme.lightThemeMode,
      darkTheme: AppTheme.darkThemeMode,
      home: BlocSelector<AppUserCubit, AppUserState, bool>(
        selector: (state) => state is AppUserAuthenticated,
        builder: (context, isAuthenticated) {
          if (!isAuthenticated) return const SignInPage();

          return CurvedNavBar(
            pages: [
              const ExpensePage(),

              // Budget Page
              const BudgetPage(),
              const DashboardPage(),
              const AiInsightsPage(),

              // Settings Page
              Center(
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthFailure) {
                      showSnackBar(
                        context,
                        'error',
                        state.message,
                        ContentType.failure,
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const Loader();
                    }
                    return GestureDetector(
                      onTap: () => context.read<AuthBloc>().add(AuthSignOut()),
                      child: const Text('Settings'),
                    );
                  },
                ),
              ),
            ],
            onPageChanged: updatePage,
          );
        },
      ),
    );
  }
}
