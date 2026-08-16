import 'package:finpilot/features/auth/screens/auth_gate.dart';
import 'package:finpilot/features/budgets/screens/budget_screen.dart';
import 'package:finpilot/features/dashboard/screens/dashboard_screen.dart';
import 'package:finpilot/features/goals/screens/goals_screen.dart';
import 'package:finpilot/features/insights/screens/insights_screen.dart';
import 'package:finpilot/features/profile/screens/profile_screen.dart';
import 'package:finpilot/features/reports/screens/reports_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Firebase gibi platform servislerini uygulama başlatılmadan önce hazırlar.
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase bağlantısını platforma ait yapılandırma ile başlatır.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

  runApp(const FinPilotApp());
}

const bool bypassAuthentication = false;

class FinPilotApp extends StatelessWidget {
  const FinPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinPilot',

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/budgets': (context) => BudgetScreen(),
        '/goals': (context) => GoalsScreen(),
        '/reports': (context) => ReportsScreen(),
        '/insights': (context) => InsightsScreen(),
        '/profile': (context) => ProfileScreen(),
      },

      // Oturum durumuna göre Login veya Dashboard ekranını gösterir.
      // home: const AuthGate(),
      home: bypassAuthentication ? const DashboardScreen() : const AuthGate(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FinPilot')),
      body: const Center(
        child: Text(
          'FinPilot\'a Hoş Geldiniz',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
