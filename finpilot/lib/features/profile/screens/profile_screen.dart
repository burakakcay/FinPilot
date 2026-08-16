import 'package:finpilot/features/auth/services/auth_service.dart';
import 'package:finpilot/shared/widgets/app_navigation_layout.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService authService = AuthService();

  bool isSendingResetEmail = false;

  Future<void> sendResetEmail() async {
    final email = authService.currentUser?.email;

    if (email == null || email.isEmpty) return;

    setState(() {
      isSendingResetEmail = true;
    });

    try {
      await authService.resetPassword(email: email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şifre sıfırlama bağlantısı gönderilemedi.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSendingResetEmail = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = authService.currentUser;
    final isDarkMode =
        widget.themeMode == ThemeMode.dark ||
        (widget.themeMode == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    return AppNavigationLayout(
      selectedIndex: 5,
      title: 'Profil ve Ayarlar',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Profil Bilgileri',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person_outline,
                      size: 40,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('E-posta'),
                    subtitle: Text(user?.email ?? 'E-posta bulunamadı'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.fingerprint),
                    title: const Text('Kullanıcı ID'),
                    subtitle: Text(user?.uid ?? 'Kullanıcı bulunamadı'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Güvenlik',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_reset_outlined),
              title: const Text('Şifreyi Sıfırla'),
              subtitle: const Text(
                'E-posta adresinize şifre yenileme bağlantısı gönderilir.',
              ),
              trailing: isSendingResetEmail
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: isSendingResetEmail ? null : sendResetEmail,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Görünüm',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(
                isDarkMode
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
              ),
              title: Text(isDarkMode ? 'Koyu Tema' : 'Açık Tema'),
              subtitle: const Text('Uygulamanın renk görünümünü değiştirin.'),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  widget.onThemeModeChanged(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
