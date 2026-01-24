import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            onTap: onPressed ??
                () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    // No navigation history (e.g., deep link), go to home
                    context.go('/');
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
