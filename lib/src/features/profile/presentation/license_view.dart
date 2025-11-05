import 'package:flutter/material.dart';

/// A view that displays the licenses for all packages used in the application.
///
/// This view uses Flutter's built-in [LicensePage] to automatically collect
/// and display licenses from all packages that include LICENSE files.
class LicenseView extends StatelessWidget {
  /// Constructor
  const LicenseView({super.key});

  @override
  Widget build(BuildContext context) {
    return const LicensePage(
      applicationName: 'Namma Wallet',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Namma Flutter',
    );
  }
}
