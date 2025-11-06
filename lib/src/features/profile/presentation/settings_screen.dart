import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/widgets/custom_back_button.dart';

/// class [SettingsScreen] is a Widget which can be placed on the setting screen
/// to download the model
class SettingsScreen extends StatelessWidget {
  /// Constructor
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: const Text('Settings'),
      ),
      body: ListView(
        children: const [
           Text('This page is empty')
        ],
      ),
    );
  }
}
