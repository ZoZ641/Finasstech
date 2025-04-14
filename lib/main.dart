import 'package:finasstech/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:finasstech/core/theme/theme.dart';
import 'package:finasstech/core/utils/navbar/curved_nav_bar.dart';
import 'package:finasstech/core/utils/navbar/navbar.dart';
import 'package:finasstech/features/analytics/presentation/pages/ai_insights_page.dart';
import 'package:finasstech/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:finasstech/features/auth/presentation/pages/signin_page.dart';
import 'package:finasstech/features/budgeting/presentation/pages/create_budget_page.dart';
import 'package:finasstech/features/dashboard/presentaion/pages/dashboard_page.dart';
import 'package:finasstech/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/common/widgets/loader.dart';
import 'core/utils/show_snackbar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<AppUserCubit>()),
        BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
      ],
      //LEGACY this allow me to preview the app on different devices
      child: DevicePreview(
        enabled: false,
        builder: (context) => const MyApp(), // Wrap your app
      ),
    ),
  );

  /*runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(), // Wrap your app
    ),
  );*/
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
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
      //LEGACY this allow me to preview the app on different devices
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
                Center(child: Text('Transactions')),
                CreateBudgetPage(),
                DashboardPage(),
                AiInsightsPage(),
                //ToDo: move this with it's imports to it's own file
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
                        child: Text('Settings'),
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
      ), //? This is the default material navbar
      /*home: Navbar(
        pages: [
          Center(child: Text('Transactions')),
          CreateBudgetPage(),
          DashboardPage(),
          AiInsightsPage(),
          Center(child: Text('Settings')),
        ],
        onPageChanged: updatePage,
      ),*/
    );
  }
}
