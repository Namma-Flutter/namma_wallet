import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/data/sample_ticket_data.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_extension.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_interface.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/theme/theme_provider.dart';
import 'package:namma_wallet/src/common/widgets/rounded_back_button.dart';
import 'package:namma_wallet/src/common/widgets/snackbar_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final IHapticService hapticService = getIt<IHapticService>();
  bool _isHapticEnabled = false;
  late ILogger _iLogger;
  @override
  void initState() {
    super.initState();
    _iLogger = getIt<ILogger>();
    unawaited(_initHapticFlag());
  }

  Future<void> _initHapticFlag() async {
    try {
      await hapticService.loadPreference();
    } on Exception catch (e) {
      // Log error; fallback to default (false) is safe
      debugPrint('Failed to load haptic preference: $e');
    }
    if (!mounted) return;

    // Read current enabled state from the service and update UI.
    setState(() {
      _isHapticEnabled = hapticService.isEnabled;
    });
  }

  /// Persist the flag via the service
  Future<void> _saveFlag(bool value) =>
      hapticService.setEnabled(enabled: value);
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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
              // Theme Settings Section
              ThemeSectionWidget(themeProvider: themeProvider),

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
              ), // Contact Us Section
              ProfileTile(
                icon: Icons.south_america,
                title: 'Add Sample Ticket Data',
                subtitle: 'Update sample tickets for testing purposes',
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  try {
                    _iLogger
                      ..debug('Starting sample JSON data parsing')
                      ..debug('Sample JSON: $sampleTicketList');
                    // Parse the sample tickets
                    final sampleTicketsParsed = sampleTicketList
                        .map(TicketMapper.fromMap)
                        .toList();
                    _iLogger.debug(
                      'Parsed ticket length: ${sampleTicketsParsed.length}',
                    );
                    // Insert tickets into database
                    final ticketDao = getIt<ITicketDAO>();
                    for (final ticket in sampleTicketsParsed) {
                      await ticketDao.insertTicket(ticket);
                    }
                    _iLogger.info(
                      'Sample tickets parsed and inserted successfully',
                    );
                  } on Exception catch (e, stackTrace) {
                    _iLogger.error(
                      'Error occurred during sample JSON parsing',
                      e,
                      stackTrace,
                    );
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
                      // Persist via service
                      // (updates in-memory and SharedPreferences)
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

                    // Update UI
                    setState(() {
                      _isHapticEnabled = value;
                    });

                    // Optional: give immediate feedback only when enabling.
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
    required this.themeProvider,
    super.key,
  });

  final ThemeProvider themeProvider;

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
                themeProvider.isSystemMode
                    ? 'Following system settings'
                    : themeProvider.isDarkMode
                    ? 'Dark theme enabled'
                    : 'Light theme enabled',
              ),
              value: themeProvider.isDarkMode,
              onChanged: (value) async {
                if (value) {
                  await themeProvider.setDarkMode();
                } else {
                  await themeProvider.setLightMode();
                }
              },
              secondary: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('Use System Theme'),
              trailing: Switch(
                value: themeProvider.isSystemMode,
                onChanged: (value) async {
                  if (value) {
                    await themeProvider.setSystemMode();
                  } else {
                    await themeProvider.setLightMode();
                  }
                },
              ),
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
    // If trailing is interactive, ensure the
    // tile itself isn't treated as a tap target
    // even if someone accidentally passes a non-null onTap.
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
