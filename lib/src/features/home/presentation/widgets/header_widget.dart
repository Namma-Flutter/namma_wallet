import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_extension.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_interface.dart';

class UserProfileWidget extends StatelessWidget {
  UserProfileWidget({
    super.key,
  });
  final IHapticService hapticService = getIt<IHapticService>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
      child: Row(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //* Name
          const Expanded(
            child: Text(
              'Namma Wallet',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),

          //* Profile
          IconButton(
            onPressed: () async {
              hapticService.triggerHaptic(
                HapticType.selection,
              );
              await context.pushNamed(AppRoute.profile.name);
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
