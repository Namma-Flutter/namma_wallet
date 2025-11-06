import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/theme/theme_provider.dart';
import 'package:namma_wallet/src/common/widgets/custom_back_button.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

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
                context.pushNamed(AppRoute.license.name);
              },
            ),
          ),

          const SizedBox(height: 100), // Space for FAB
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
