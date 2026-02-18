import 'package:flutter/material.dart';

import 'data/session_manager.dart';
import 'screens/home/home_page.dart';
import 'screens/login/login_page.dart';
import 'theme/app_theme.dart';

class FinanceApp extends StatefulWidget {
  const FinanceApp({super.key});

  @override
  State<FinanceApp> createState() => _FinanceAppState();
}

class _FinanceAppState extends State<FinanceApp> with WidgetsBindingObserver {
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sessionManager.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _sessionManager.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: ValueListenableBuilder(
        valueListenable: _sessionManager.user,
        builder: (context, user, _) {
          if (user == null) {
            return LoginPage(sessionManager: _sessionManager);
          }
          return HomePage(
            sessionManager: _sessionManager,
            user: user,
          );
        },
      ),
    );
  }
}
