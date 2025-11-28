import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/theme/app_theme.dart';
import 'package:namma_wallet/src/features/settings/application/ai_service_status.dart';
import 'package:provider/provider.dart';

class AIStatusWidget extends StatelessWidget {
  const AIStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: getIt<AIServiceStatus>(),
      child: Consumer<AIServiceStatus>(
        builder: (context, status, child) {
          if (status.isGemmaSupported) {
            return const SizedBox.shrink();
          }

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Theme.of(context).colorScheme.warningContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 24,
                        color: Theme.of(context).colorScheme.onWarningContainer,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'AI Service Status',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onWarningContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    status.errorMessage ?? 'Gemma AI is not supported on this platform.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onWarningContainer,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
