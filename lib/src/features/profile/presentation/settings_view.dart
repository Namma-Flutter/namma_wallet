import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/widgets/custom_back_button.dart';

/// class [SettingsView] is a Widget which can be placed on the setting screen
/// to download the model
class SettingsView extends StatelessWidget {
  /// Constructor
  const SettingsView({super.key});

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
