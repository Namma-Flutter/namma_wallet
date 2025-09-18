import 'package:flutter/material.dart';
import 'package:namma_wallet/src/core/styles/styles.dart';

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
            onTap: onPressed ?? () => Navigator.of(context).pop(),
            child: const Icon(Icons.chevron_left, size: 28),
          ),
        ),
      ),
    );
  }
}
