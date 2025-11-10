import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/services/haptic_service_extension.dart';
import 'package:namma_wallet/src/common/services/haptic_service_interface.dart';
import 'package:namma_wallet/src/common/theme/theme_provider.dart';
import 'package:namma_wallet/src/common/widgets/custom_back_button.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final IHapticService hapticService = getIt<IHapticService>();
  bool _isHapticEnabled = false;
  @override
  void initState() {
    super.initState();
    _initHapticFlag();
  }

  Future<void> _initHapticFlag() async {
    await hapticService.loadPreference();
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
        leading: const CustomBackButton(),
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Settings Section
          ThemeSectionWidget(themeProvider: themeProvider),

          const SizedBox(height: 24),

          // Contributors Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Contributors'),
              subtitle: const Text('View project contributors'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                hapticService.triggerHaptic(
                  HapticType.selection,
                );
                context.pushNamed(AppRoute.contributors.name);
              },
            ),
          ),

          const SizedBox(height: 8),

          // License Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('Licenses'),
              subtitle: const Text('View open source licenses'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                hapticService.triggerHaptic(
                  HapticType.selection,
                );
                context.pushNamed(AppRoute.license.name);
              },
            ),
          ),

          // Haptics Enabled
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.vibration_outlined),
              title: const Text('Haptics Enabled'),
              trailing: Switch(
                value: _isHapticEnabled,
                onChanged: (value) async {
                  // Persist via service
                  // (updates in-memory and SharedPreferences)
                  await _saveFlag(value);
                  if (!mounted) return;

                  // Update UI
                  setState(() {
                    _isHapticEnabled = value;
                  });

                  // Optional: give immediate feedback only when enabling.
                  if (value) hapticService.triggerHaptic(HapticType.selection);
                },
              ),
            ),
          ),
          // const SizedBox(height: 100), // Space for FAB
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.pushNamed(AppRoute.dbViewer.name);
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
              onChanged: (value) {
                if (value) {
                  themeProvider.setDarkMode();
                } else {
                  themeProvider.setLightMode();
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
                onChanged: (value) {
                  if (value) {
                    themeProvider.setSystemMode();
                  } else {
                    themeProvider.setLightMode();
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
