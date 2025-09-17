import 'package:flutter/material.dart';
import 'package:namma_wallet/src/features/calendar/presentation/calendar_page.dart';
import 'package:namma_wallet/src/features/home/presentation/home_page.dart';
import 'package:namma_wallet/src/features/profile/presentation/profile_page.dart';

import 'package:namma_wallet/src/features/scanner/presentation/scanner_view.dart';

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
                selectedIcon: Icon(Icons.qr_code),
                icon: Icon(Icons.qr_code_scanner_outlined),
                label: 'Scanner',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.more),
                icon: Icon(Icons.more_outlined),
                label: 'More',
              ),
            ],
          ),
          body: <Widget>[
            const HomePage(),
            const CalendarPage(),
            const ScannerView(),
            const ProfilePage(),
          ][currentPageIndex],
        ),
      );
}
