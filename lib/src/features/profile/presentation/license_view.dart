import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// A view that displays the licenses for all packages used in the application.
///
/// This view uses Flutter's built-in [LicensePage] to automatically collect
/// and display licenses from all packages that include LICENSE files.
class LicenseView extends StatelessWidget {
  /// Constructor
  const LicenseView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final String applicationVersion;
        if (snapshot.hasError) {
          applicationVersion = 'Error: ${snapshot.error}';
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          applicationVersion = 'loading...';
        } else if (snapshot.hasData) {
          final packageInfo = snapshot.data!;
          applicationVersion =
              '${packageInfo.version}+${packageInfo.buildNumber}';
        } else {
          applicationVersion = '';
        }

        return LicensePage(
          applicationName: 'Namma Wallet',
          applicationVersion: applicationVersion,
          applicationLegalese: '© 2026 Namma Flutter',
        );
      },
    );
  }
}
