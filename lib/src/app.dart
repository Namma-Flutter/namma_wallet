import 'package:flutter/material.dart';
import 'package:namma_wallet/src/features/home/presentation/home_page.dart';

class NammaWalletApp extends StatelessWidget {
  const NammaWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'NammaWallet',
      home: HomePage(),
    );
  }
}
