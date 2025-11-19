import 'package:flutter/material.dart';
import 'package:namma_wallet/src/features/share/presentation/share_content_view.dart';

/// Test button to manually trigger the share modal
/// Add this to any screen for testing the share functionality
class ShareTestButton extends StatelessWidget {
  const ShareTestButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        showShareContentModal(
          context,
          onShare: (type, title) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selected: $title (${type.name})'),
                backgroundColor: Colors.green,
              ),
            );
          },
        );
      },
      icon: const Icon(Icons.share),
      label: const Text('Test Share'),
    );
  }
}
