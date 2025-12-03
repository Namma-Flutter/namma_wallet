import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/database/user_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/domain/models/user.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_extension.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_interface.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/widget/widget_service_interface.dart';
import 'package:namma_wallet/src/common/widgets/rounded_back_button.dart';

class DbViewerView extends StatefulWidget {
  const DbViewerView({super.key});

  @override
  State<DbViewerView> createState() => _DbViewerViewState();
}

class _DbViewerViewState extends State<DbViewerView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<User> users = <User>[];
  List<Ticket> tickets = <Ticket>[];
  final IHapticService hapticService = getIt<IHapticService>();
  final IWidgetService iWidgetService = getIt<IWidgetService>();

  late ILogger _iLogger;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _iLogger = getIt<ILogger>();
    unawaited(_load());
  }

  Future<void> _load() async {
    final userDao = getIt<IUserDAO>();
    final ticketDao = getIt<ITicketDAO>();
    final u = await userDao.fetchAllUsers();
    final t = await ticketDao.getAllTickets();
    if (!mounted) return;
    setState(() {
      users = u;
      tickets = t;
    });
    hapticService.triggerHaptic(HapticType.success);
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
      leading: const RoundedBackButton(),
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
                title: Text(user.fullName),
                subtitle: Text(user.email),
                trailing: Text('ID: ${user.userId}'),
              ),
            );
          },
        ),
        ListView.builder(
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final t = tickets[index];
            final subtitle = t.secondaryText;
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(
                  t.ticketId.toString(),
                ),
                subtitle: Text(subtitle),
                // trailing: Text('${t['amount'] ?? 'N/A'}'),
                onTap: () => showTicketDetails(context, t, subtitle),
              ),
            );
          },
        ),
      ],
    ),
  );

  Future<void> showTicketDetails(
    BuildContext context,
    Ticket t,
    String subtitle,
  ) async {
    await showDialog<void>(
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
                    children: (t.extras ?? [])
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: [
                                  TextSpan(
                                    text: '${entry.title}: ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: entry.value,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              if (!kIsWeb)
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await iWidgetService.updateWidgetWithTicket(t);
                    } on Object catch (e, stackTrace) {
                      _iLogger.error(
                        'Error saving multiple tickets to widget',
                        e,
                        stackTrace,
                      );
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
      },
    );
  }
}
