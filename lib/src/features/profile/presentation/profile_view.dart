import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/theme/theme_provider.dart';
import 'package:namma_wallet/src/common/widgets/custom_back_button.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            spacing: 8,
            children: [
              // Theme Settings Section
              ThemeSectionWidget(themeProvider: themeProvider),

              const SizedBox(
                height: 8,
              ),
              // Contributors Section
              ProfileTile(
                icon: Icons.people_outline,
                title: 'Contributors',
                subtitle: 'View project contributors',
                onTap: () {
                  context.pushNamed(AppRoute.contributors.name);
                },
              ),

              // Licenses Section
              ProfileTile(
                icon: Icons.article_outlined,
                title: 'Licenses',
                subtitle: 'View open source licenses',
                onTap: () {
                  context.pushNamed(AppRoute.license.name);
                },
              ),

              // Contact Us Section
              ProfileTile(
                icon: Icons.contact_mail_outlined,
                title: 'Contact Us',
                subtitle: 'Get support or send feedback',
                onTap: () async {
                  final uri = Uri(
                    scheme: 'mailto',
                    path: 'support@nammawallet.com',
                  );

                  try {
                    if (!await canLaunchUrl(uri)) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'No email app found. '
                              'Please install a mail client.',
                            ),
                          ),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Failed to open email app. Please try again.',
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
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

class ProfileTile extends StatelessWidget {
  const ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
