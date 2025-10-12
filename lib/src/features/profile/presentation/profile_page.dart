import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:namma_wallet/src/common/helper/app_info.dart';
import 'package:namma_wallet/src/common/helper/send_email.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/features/profile/presentation/widgets/profile_page_card_widget.dart';

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
  String _version = '';

  void _launchEmail() {
    EmailHelper.sendEmail(
      subject: 'App Support',
      body: 'Hi, I need help regarding ...',
    );
  }

  Future<void> _loadVersion() async {
    final version = await getAppVersion();
    setState(() {
      _version = version;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 28,
                  backgroundImage: const NetworkImage(
                    'https://avatars.githubusercontent.com/u/583231?v=4',
                  ),
                  backgroundColor: Colors.grey[200],
                ),
                title: const Text(
                  'Hii User 🖐',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: const Text(
                  'Namma Wallet',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          ProfilePageCard(
            icon: Icons.group,
            title: 'Contributors',
            onTap: () {
              context.pushNamed(AppRoute.contributors.name);
            },
          ),

          ProfilePageCard(
            icon: Icons.mail_outline,
            iconColor: Colors.green,
            title: 'Contact Us',
            onTap: _launchEmail,
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              "Version: $_version",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
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
