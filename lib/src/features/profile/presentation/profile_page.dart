import 'package:flutter/material.dart';
import 'package:namma_wallet/src/core/services/database_helper.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(
          child: Text('Profile page'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const _DbViewerPage()),
            );
          },
          label: const Text('View DB'),
          icon: const Icon(Icons.storage),
        ),
      );
}

class _DbViewerPage extends StatefulWidget {
  const _DbViewerPage();

  @override
  State<_DbViewerPage> createState() => _DbViewerPageState();
}

class _DbViewerPageState extends State<_DbViewerPage>
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
    final DatabaseHelper db = DatabaseHelper.instance;
    final List<Map<String, Object?>> u = await db.fetchAllUsers();
    final List<Map<String, Object?>> t = await db.fetchTicketsWithUser();
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
            _UsersList(users: users),
            _TicketsList(tickets: tickets),
          ],
        ),
      );
}

class _UsersList extends StatelessWidget {
  const _UsersList({required this.users});
  final List<Map<String, Object?>> users;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(child: Text('No users'));
    }
    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final Map<String, Object?> user = users[index];
        return ListTile(
          leading: const Icon(Icons.person),
          title: Text((user['full_name'] ?? '') as String),
          subtitle: Text(((user['email'] ?? '') as String).toString()),
          trailing: Text('#${user['user_id']}'),
        );
      },
    );
  }
}

class _TicketsList extends StatelessWidget {
  const _TicketsList({required this.tickets});
  final List<Map<String, Object?>> tickets;

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return const Center(child: Text('No tickets'));
    }
    return ListView.separated(
      itemCount: tickets.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final Map<String, Object?> t = tickets[index];
        final String title = '${t['ticket_type']} • ${t['provider']}';
        final String subtitle =
            '${t['source'] ?? t['event_name'] ?? ''} → ${t['destination'] ?? ''}';
        return ListTile(
          leading: const Icon(Icons.receipt_long),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text((t['user_full_name'] ?? '') as String),
              Text('₹${(t['amount'] ?? 0).toString()}'),
            ],
          ),
        );
      },
    );
  }
}
