import 'package:flutter/material.dart';
import 'package:namma_wallet/src/core/routing/app_router.dart';

class NammaWalletApp extends StatefulWidget {
  const NammaWalletApp({super.key});

  @override
  State<NammaWalletApp> createState() => _NammaWalletAppState();
}

class _NammaWalletAppState extends State<NammaWalletApp> {
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'NammaWallet',
        routerConfig: router,
      );
}
