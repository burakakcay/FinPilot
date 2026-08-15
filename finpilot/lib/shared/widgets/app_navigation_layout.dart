import 'package:finpilot/features/auth/screens/auth_gate.dart';
import 'package:finpilot/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';

class AppNavigationLayout extends StatefulWidget {
  const AppNavigationLayout({
    super.key,
    required this.selectedIndex,
    required this.title,
    required this.body,
    this.floatingActionButton,
  });

  final int selectedIndex;
  final String title;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  State<AppNavigationLayout> createState() => _AppNavigationLayoutState();
}

class _AppNavigationLayoutState extends State<AppNavigationLayout> {
  final AuthService authService = AuthService();

  bool isLoggingOut = false;

  // Seçilen ana sayfaya yönlendirme yapar.
  void selectDestination(int index) {
    if (index == widget.selectedIndex) return;

    const routeNames = ['/dashboard', '/budgets', '/goals'];
    final routeName = routeNames[index];

    Navigator.pushReplacementNamed(context, routeName);
  }

  // Çıkış işleminden önce kullanıcıdan onay alır.
  Future<void> confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Çıkış yapılsın mı?'),
          content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Çıkış Yap'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) return;

    await logout();
  }

  // Firebase oturumunu kapatır; AuthGate kullanıcıyı giriş ekranına yönlendirir.
  Future<void> logout() async {
    setState(() {
      isLoggingOut = true;
    });

    try {
      await authService.logout();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthGate()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Çıkış yapılırken bir hata oluştu.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 92,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.account_balance_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 4),
                Text(
                  'FinPilot',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: NavigationRail(
                    selectedIndex: widget.selectedIndex,
                    labelType: NavigationRailLabelType.all,
                    onDestinationSelected: selectDestination,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: Text('Ana Sayfa'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.account_balance_wallet_outlined),
                        selectedIcon: Icon(Icons.account_balance_wallet),
                        label: Text('Bütçelerim'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.savings_outlined),
                        selectedIcon: Icon(Icons.savings),
                        label: Text('Hedeflerim'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      IconButton(
                        tooltip: 'Çıkış Yap',
                        onPressed: isLoggingOut ? null : confirmLogout,
                        icon: isLoggingOut
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.logout),
                      ),
                      Text('Çıkış Yap', style: theme.textTheme.labelSmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: Text(widget.title),
                  automaticallyImplyLeading: false,
                ),
                Expanded(child: widget.body),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
