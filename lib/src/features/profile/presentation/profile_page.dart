import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:namma_wallet/src/common/routing/app_routes.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: FutureBuilder<List<Contributor>>(
        future: _contributorsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No contributors found.'));
          }

          final contributors = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: contributors.length,
            itemBuilder: (context, index) {
              final contributor = contributors[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(contributor.avatarUrl),
                    radius: 24,
                  ),
                  title: Text(contributor.name),
                  subtitle: Text(contributor.profileUrl),
                  onTap: () {
                    // You can integrate url_launcher here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Open: ${contributor.profileUrl}')),
                    );
                  },
                ),
              );
            },
          );
        },
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
