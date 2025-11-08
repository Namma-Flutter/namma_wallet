import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/widgets/custom_back_button.dart';

class ExportView extends StatelessWidget {
  const ExportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: const Text('Export'),
      ),
      body: const Center(
        child: Text('Export functionality coming soon'),
      ),
    );
  }
}
