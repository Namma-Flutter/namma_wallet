import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
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
          backgroundColor: AppColor.primaryColor,
          child: InkWell(
            onTap: onPressed ?? () => context.pop(),
            child: const Icon(Icons.chevron_left, size: 28),
          ),
        ),
      ),
    );
  }
}
