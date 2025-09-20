import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';
import 'package:namma_wallet/src/common/services/database_helper.dart';
import 'package:namma_wallet/src/common/widgets/custom_back_button.dart';

class DbViewerPage extends StatefulWidget {
  const DbViewerPage({super.key});

  @override
  State<DbViewerPage> createState() => _DbViewerPageState();
}

class _DbViewerPageState extends State<DbViewerPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<Map<String, Object?>> users = <Map<String, Object?>>[];
  List<Map<String, Object?>> tickets = <Map<String, Object?>>[];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final db = DatabaseHelper.instance;
    final u = await db.fetchAllUsers();
    final t = await db.fetchTravelTicketsWithUser();
    if (!mounted) return;
    setState(() {
      users = u;
      tickets = t;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Database Viewer'),
          leading: const CustomBackButton(),
          bottom: TabBar(
            controller: _tabController,
            tabs: const <Widget>[
              Tab(text: 'Users'),
              Tab(text: 'Tickets'),
            ],
          ),
          actions: <Widget>[
            IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('${user['full_name']}'),
                    subtitle: Text('${user['email']}'),
                    trailing: Text('ID: ${user['user_id']}'),
                  ),
                );
              },
            ),
            ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final t = tickets[index];
                final subtitle =
                    '${t['provider_name']} - ${t['source_location']} → ${t['destination_location']}';
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                        '${t['pnr_number'] ?? t['booking_reference'] ?? 'N/A'}'),
                    subtitle: Text(subtitle),
                    trailing: Text('${t['amount'] ?? 'N/A'}'),
                    onTap: () => showTicketDetails(context, t, subtitle),
                  ),
                );
              },
            ),
          ],
        ),
      );

  void showTicketDetails(
      BuildContext context, Map<String, Object?> t, String subtitle) {
    showDialog<void>(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: t.entries
                          .map((entry) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: [
                                      TextSpan(
                                        text: '${entry.key}: ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${entry.value}',
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    const iOSWidgetName = 'TicketHomeWidget';
                    const androidWidgetName = 'TicketHomeWidget';
                    const dataKey = 'ticket_data';
                    await HomeWidget.saveWidgetData(dataKey, jsonEncode(t));

                    await HomeWidget.updateWidget(
                        androidName: androidWidgetName, iOSName: iOSWidgetName);
                    if (context.mounted) {
                      context.pop();
                    }
                  },
                  child: const Text('Pin to Home Screen'),
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          );
        });
  }
}
