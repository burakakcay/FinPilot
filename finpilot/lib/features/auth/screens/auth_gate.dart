import 'package:finpilot/features/auth/screens/login_screen.dart';
import 'package:finpilot/features/dashboard/screens/dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Firebase oturum değişikliklerini dinleyerek doğru başlangıç ekranını seçer.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // Oturumu açık kullanıcılar dashboard'a yönlendirilir.
          return const DashboardScreen();
        } else {
          // Oturumu olmayan kullanıcılar giriş ekranını görür.
          return const LoginScreen();
        }
      },
    );
  }
}
