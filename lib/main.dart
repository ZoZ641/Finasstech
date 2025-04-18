import 'package:finasstech/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:finasstech/core/theme/theme.dart';
import 'package:finasstech/core/utils/navbar/curved_nav_bar.dart';
import 'package:finasstech/core/utils/navbar/navbar.dart';
import 'package:finasstech/features/analytics/presentation/pages/ai_insights_page.dart';
import 'package:finasstech/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:finasstech/features/auth/presentation/pages/signin_page.dart';
import 'package:finasstech/features/budgeting/presentation/bloc/budget_bloc.dart';
import 'package:finasstech/features/budgeting/presentation/pages/create_budget_page.dart';
import 'package:finasstech/features/dashboard/presentaion/pages/dashboard_page.dart';
import 'package:finasstech/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/common/widgets/loader.dart';
import 'core/utils/show_snackbar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import 'features/budgeting/domain/entities/budget.dart';
import 'features/budgeting/presentation/pages/budget_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<AppUserCubit>()),
        BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
        BlocProvider(create: (_) => serviceLocator<BudgetBloc>()),
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
  Map<String, double> _budgetUsage = {};
  Budget? _latestBudget;

  void updatePage(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // Check if budget data exists when app starts
    debugPrint('🔍 Checking for existing budget data...');
    context.read<BudgetBloc>().add(CheckForExistingBudgetData());
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
        selector: (state) {
          return state is AppUserAuthenticated;
          // TODO: return selected state
        },
        builder: (context, state) {
          if (state) {
            return CurvedNavBar(
              pages: [
                const Center(child: Text('Transactions')),

                //ToDo: fix the sates in the budget feature
                // Budget page with BlocConsumer
                BlocConsumer<BudgetBloc, BudgetState>(
                  listener: (context, state) {
                    debugPrint('📣 BudgetBloc State: ${state.runtimeType}');

                    if (state is BudgetDataExistsState) {
                      debugPrint(
                        '📊 Budget data exists: ${state.hasExistingData}',
                      );
                      if (state.hasExistingData) {
                        debugPrint('🔄 Getting latest budget...');
                        context.read<BudgetBloc>().add(GetLatestBudgetEvent());
                      }
                    }

                    if (state is BudgetCreated) {
                      debugPrint(
                        '✅ Budget created with ID: ${state.budget.id}',
                      );
                      setState(() {
                        _latestBudget = state.budget;
                      });
                      context.read<BudgetBloc>().add(
                        CalculateBudgetUsageEvent(budget: state.budget),
                      );
                    }

                    if (state is BudgetUpdated) {
                      debugPrint(
                        '🔄 Budget updated with ID: ${state.budget.id}',
                      );
                      setState(() {
                        _latestBudget = state.budget;
                      });
                      context.read<BudgetBloc>().add(
                        CalculateBudgetUsageEvent(budget: state.budget),
                      );
                    }

                    if (state is BudgetLoaded) {
                      debugPrint(
                        '📋 Budget loaded: ${state.budget?.id ?? "null"}',
                      );
                      if (state.budget != null) {
                        setState(() {
                          _latestBudget = state.budget;
                        });
                        context.read<BudgetBloc>().add(
                          CalculateBudgetUsageEvent(budget: state.budget),
                        );
                      }
                    }

                    if (state is BudgetUsageCalculated) {
                      debugPrint('📊 Budget usage calculated');
                      setState(() {
                        _budgetUsage = state.usageByCategory;
                      });
                    }

                    if (state is BudgetError) {
                      debugPrint('❌ Budget error: ${state.message}');
                    }
                  },
                  builder: (context, state) {
                    if (state is BudgetLoading) {
                      debugPrint('⏳ Budget loading...');
                      // If we already have a budget, show it while loading
                      if (_latestBudget != null) {
                        debugPrint(
                          '🎯 Showing existing BudgetDashboard while loading',
                        );
                        return BudgetDashboard(
                          budget: _latestBudget!,
                          usage: _budgetUsage,
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    }

                    // If we have a budget stored in state variable, show the dashboard
                    if (_latestBudget != null) {
                      debugPrint(
                        '🎯 Showing BudgetDashboard with latest budget',
                      );
                      return BudgetDashboard(
                        budget: _latestBudget!,
                        usage: _budgetUsage,
                      );
                    }

                    // Otherwise show the create budget page
                    debugPrint('🎯 Showing CreateBudgetPage');
                    return const CreateBudgetPage();
                  },
                ),

                const DashboardPage(),
                const AiInsightsPage(),

                // Settings page
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
                        onTap:
                            () => context.read<AuthBloc>().add(AuthSignOut()),
                        child: const Text('Settings'),
                      );
                    },
                  ),
                ),
              ],
              onPageChanged: updatePage,
            );
          }

          return const SignInPage();
        },
      ),
    );
  }
}
