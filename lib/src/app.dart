import 'package:flutter/material.dart';
import 'package:namma_wallet/src/features/calendar/presentation/calendar_page.dart';
import 'package:namma_wallet/src/features/profile/presentation/profile_page.dart';

import 'features/ticket_parser/presentation/ticket_scanner_page.dart';

class NammaWalletApp extends StatefulWidget {
  const NammaWalletApp({super.key});

  @override
  State<NammaWalletApp> createState() => _NammaWalletAppState();
}

class _NammaWalletAppState extends State<NammaWalletApp> {
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'NammaWallet',
        home: Scaffold(
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            indicatorColor: Colors.amber,
            selectedIndex: currentPageIndex,
            destinations: const <Widget>[
              NavigationDestination(
                selectedIcon: Icon(Icons.home),
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.calendar_month),
                icon: Icon(Icons.calendar_month_outlined),
                label: 'Calender',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.person),
                icon: Icon(Icons.person_outline),
                label: 'Messages',
              ),
            ],
          ),
          body: <Widget>[
            ScannerScreen(),
            const CalendarPage(),
            const ProfilePage(),
          ][currentPageIndex],
        ),);
}
