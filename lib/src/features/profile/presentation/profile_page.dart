import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/theme/theme_provider.dart';
import 'package:namma_wallet/src/common/widgets/custom_back_button.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// ----------------- Model -----------------
class Contributor {
  Contributor({
    required this.name,
    required this.avatarUrl,
    required this.profileUrl,
  });

  factory Contributor.fromJson(Map<String, dynamic> json) {
    return Contributor(
      name: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
      profileUrl: json['html_url'] as String,
    );
  }
  final String name;
  final String avatarUrl;
  final String profileUrl;
}

// ----------------- Profile Page -----------------
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<List<Contributor>> _contributorsFuture;

  @override
  void initState() {
    super.initState();
    _contributorsFuture = _fetchContributors();
  }

  Future<List<Contributor>> _fetchContributors() async {
    final response = await http.get(
      Uri.parse(
          'https://api.github.com/repos/Namma-Flutter/namma_wallet/contributors'),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as List<dynamic>;
      return body
          .map((json) => Contributor.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load contributors');
    }
  }

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
          _buildThemeSection(context, themeProvider),

          const SizedBox(height: 24),

          // Contributors Section
          _buildContributorsSection(context),

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

  Widget _buildThemeSection(BuildContext context, ThemeProvider themeProvider) {
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

  Widget _buildContributorsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.people_outline, size: 24),
              SizedBox(width: 12),
              Text(
                'Contributors',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Contributor>>(
          future: _contributorsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            } else if (snapshot.hasError) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 8),
                      Text('Error: ${snapshot.error}'),
                    ],
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('No contributors found.')),
                ),
              );
            }

            final contributors = snapshot.data!;
            return Column(
              children: contributors
                  .map((contributor) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(contributor.avatarUrl),
                            radius: 24,
                          ),
                          title: Text(
                            contributor.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            contributor.profileUrl,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.open_in_new, size: 20),
                          onTap: () async {
                            final url = Uri.parse(contributor.profileUrl);
                            try {
                              await launchUrl(url);
                            } on Exception catch (_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Could not open '
                                      '${contributor.profileUrl}',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
