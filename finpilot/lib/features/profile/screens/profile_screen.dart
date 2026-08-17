import 'package:finpilot/features/auth/services/auth_service.dart';
import 'package:finpilot/features/profile/services/seed_data_service.dart';
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
  final SeedDataService seedDataService = SeedDataService();

  bool isSendingResetEmail = false;
  bool isSeedingData = false;

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

  Future<void> seedSampleData() async {
    setState(() {
      isSeedingData = true;
    });

    try {
      await seedDataService.seedSampleData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test verileri Firestore\'a yüklendi.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test verileri yüklenemedi: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSeedingData = false;
        });
      }
    }
  }

  Future<void> editDisplayName() async {
    final user = authService.currentUser;
    if (user == null) return;

    final controller = TextEditingController(text: user.displayName ?? '');

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('İsmi Düzenle'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'İsim Soyisim',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  Navigator.pop(dialogContext, name);
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newName == null || newName.isEmpty) return;

    try {
      await user.updateDisplayName(newName);
      await user.reload();

      if (!mounted) return;

      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İsim başarıyla güncellendi.')),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('İsim güncellenemedi.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = authService.currentUser;

    final displayName = user?.displayName?.trim();
    final profileName = displayName == null || displayName.isEmpty
        ? 'FinPilot Kullanıcısı'
        : displayName;

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
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person_outline,
                      size: 38,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profileName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user?.email ?? 'E-posta bulunamadı',
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_outlined,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Hesap aktif',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    tooltip: 'İsmi Düzenle',
                    onPressed: editDisplayName,
                    icon: const Icon(Icons.edit_outlined),
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
          const SizedBox(height: 24),
          Text(
            'Geliştirici Araçları',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_upload_outlined),
              title: const Text('Test Verilerini Yükle'),
              subtitle: const Text(
                'Örnek gelir, gider, bütçe ve hedef verileri ekler.',
              ),
              trailing: isSeedingData
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: isSeedingData ? null : seedSampleData,
            ),
          ),
        ],
      ),
    );
  }
}
