import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_extension.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_interface.dart';
import 'package:namma_wallet/src/common/theme/theme_notifier.dart';
import 'package:namma_wallet/src/common/widgets/rounded_back_button.dart';
import 'package:namma_wallet/src/common/widgets/snackbar_widget.dart';
import 'package:namma_wallet/src/features/profile/presentation/ai_status_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  bool _isHapticEnabled = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initHapticFlag());
  }

  Future<void> _initHapticFlag() async {
    final hapticService = getIt<IHapticService>();
    try {
      await hapticService.loadPreference();
    } on Exception catch (e) {
      debugPrint('Failed to load haptic preference: $e');
    }
    if (!mounted) return;

    setState(() {
      _isHapticEnabled = hapticService.isEnabled;
    });
  }

  Future<void> _saveFlag(bool value) async {
    final hapticService = getIt<IHapticService>();
    await hapticService.setEnabled(enabled: value);
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final hapticService = getIt<IHapticService>();

    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(),
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            spacing: 8,
            children: [
              const AIStatusWidget(),
              const SizedBox(height: 8),
              // Theme Settings Section
              ThemeSectionWidget(
                themeState: themeState,
                themeNotifier: themeNotifier,
              ),

              const SizedBox(height: 8),

              // Contributors Section
              ProfileTile(
                icon: Icons.people_outline,
                title: 'Contributors',
                subtitle: 'View project contributors',
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await context.pushNamed(AppRoute.contributors.name);
                },
              ),

              // Licenses Section
              ProfileTile(
                icon: Icons.article_outlined,
                title: 'Licenses',
                subtitle: 'View open source licenses',
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await context.pushNamed(AppRoute.license.name);
                },
              ),

              // Contact Us Section
              ProfileTile(
                icon: Icons.contact_mail_outlined,
                title: 'Contact Us',
                subtitle: 'Get support or send feedback',
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final uri = Uri(
                    scheme: 'mailto',
                    path: 'support@nammawallet.com',
                  );

                  try {
                    if (!await canLaunchUrl(uri)) {
                      if (context.mounted) {
                        showSnackbar(
                          context,
                          'No email app found. Please install a mail client.',
                          isError: true,
                        );
                      }
                      return;
                    }

                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                  } on Exception {
                    if (context.mounted) {
                      showSnackbar(
                        context,
                        'Failed to open email app. Please try again.',
                        isError: true,
                      );
                    }
                  }
                },
              ),

              // Haptics Enabled
              ProfileTile(
                title: 'Haptics Enabled',
                icon: Icons.vibration_outlined,
                trailing: Switch(
                  value: _isHapticEnabled,
                  onChanged: (value) async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await _saveFlag(value);
                    } on Exception catch (e) {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Failed to save haptic preference: $e'),
                        ),
                      );
                      return;
                    }
                    if (!mounted) return;

                    setState(() {
                      _isHapticEnabled = value;
                    });

                    if (value) {
                      hapticService.triggerHaptic(HapticType.selection);
                    }
                  },
                ),
                trailingIsInteractive: true,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.pushNamed(AppRoute.dbViewer.name);
        },
        label: const Text('View DB'),
        icon: const Icon(Icons.storage),
      ),
    );
  }
}

class ThemeSectionWidget extends StatelessWidget {
  const ThemeSectionWidget({
    required this.themeState,
    required this.themeNotifier,
    super.key,
  });

  final ThemeState themeState;
  final ThemeModeNotifier themeNotifier;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.palette_outlined, size: 24),
                SizedBox(width: 12),
                Text(
                  'Appearance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: Text(
                themeState.isSystemMode
                    ? 'Following system settings'
                    : themeState.isDarkMode
                    ? 'Dark theme enabled'
                    : 'Light theme enabled',
              ),
              value: themeState.isDarkMode,
              onChanged: (value) async {
                if (value) {
                  await themeNotifier.setDarkMode();
                } else {
                  await themeNotifier.setLightMode();
                }
              },
              secondary: Icon(
                themeState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
            ),
            SwitchListTile(
              title: const Text('Use System Theme'),
              value: themeState.isSystemMode,
              onChanged: (value) async {
                if (value) {
                  await themeNotifier.setSystemMode();
                } else {
                  await themeNotifier.setLightMode();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  const ProfileTile({
    required this.icon,
    required this.title,
    required this.trailing,
    this.onTap,
    this.subtitle,
    this.trailingIsInteractive = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final void Function()? onTap;
  final bool trailingIsInteractive;

  @override
  Widget build(BuildContext context) {
    final tileOnTap = trailingIsInteractive ? null : onTap;
    final tileEnabled = onTap != null || trailingIsInteractive;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: trailing,
        onTap: tileOnTap,
        enabled: tileEnabled,
      ),
    );
  }
}
