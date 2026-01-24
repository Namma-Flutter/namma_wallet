import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';

class RoundedBackButton extends StatelessWidget {
  const RoundedBackButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: InkWell(
            onTap:
                onPressed ??
                () {
                  // Check if we can pop, otherwise go to home
                  if (Navigator.canPop(context)) {
                    context.pop();
                  } else {
                    // If nothing to pop, navigate to home
                    context.goNamed(AppRoute.home.name);
                  }
                },
            child: const Icon(
              Icons.chevron_left,
              size: 28,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
