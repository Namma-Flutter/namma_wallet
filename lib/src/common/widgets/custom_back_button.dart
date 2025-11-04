import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: InkWell(
            onTap: onPressed ?? () => context.pop(),
            child: Icon(
              Icons.chevron_left,
              size: 28,
              color: isDark ? Colors.black : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
