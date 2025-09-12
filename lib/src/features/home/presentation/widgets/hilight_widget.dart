import 'package:flutter/material.dart';

class HighlightChipsWidget extends StatelessWidget {
  const HighlightChipsWidget(
      {required this.label, required this.bgColor, super.key, this.icon});
  final Color bgColor;
  final IconData? icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50), color: bgColor),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
            ),
            if (icon != null)
              const SizedBox(
                width: 5,
              ),
            Text(label),
          ],
        ),
      ),
    );
  }
}
