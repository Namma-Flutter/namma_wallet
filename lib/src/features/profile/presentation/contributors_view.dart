import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:namma_wallet/src/common/widgets/custom_back_button.dart';
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

// ----------------- Contributors View -----------------
class ContributorsView extends StatefulWidget {
  const ContributorsView({super.key});

  @override
  State<ContributorsView> createState() => _ContributorsViewState();
}

class _ContributorsViewState extends State<ContributorsView> {
  late Future<List<Contributor>> _contributorsFuture;

  @override
  void initState() {
    super.initState();
    _contributorsFuture = _fetchContributors();
  }

  Future<List<Contributor>> _fetchContributors() async {
    final contributors = <Contributor>[];
    var page = 1;
    const perPage = 100;
    const timeout = Duration(seconds: 10);

    while (true) {
      final uri =
          Uri.parse(
            'https://api.github.com/repos/Namma-Flutter/namma_wallet/contributors',
          ).replace(
            queryParameters: {
              'per_page': perPage.toString(),
              'page': page.toString(),
            },
          );

      final response = await http
          .get(
            uri,
            headers: {
              'User-Agent': 'namma_wallet',
              'Accept': 'application/vnd.github.v3+json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as List<dynamic>;
        if (body.isEmpty) {
          break; // No more contributors
        }
        contributors.addAll(
          body.map(
            (json) => Contributor.fromJson(json as Map<String, dynamic>),
          ),
        );
        page++;
      } else {
        throw Exception(
          'Failed to load contributors: HTTP ${response.statusCode}\n'
          'Response body: ${response.body}',
        );
      }
    }

    return contributors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: const Text('Contributors'),
      ),
      body: FutureBuilder<List<Contributor>>(
        future: _contributorsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading contributors',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No contributors found.'),
              ),
            );
          }

          final contributors = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contributors.length,
            itemBuilder: (context, index) {
              final contributor = contributors[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(contributor.avatarUrl),
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
                              'Could not open ${contributor.profileUrl}',
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
