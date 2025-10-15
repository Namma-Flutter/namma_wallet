import 'package:flutter/material.dart';

class ProfilePageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;
  final Color? trailingIconColor;
  final IconData trailingIcon;

  const ProfilePageCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = Colors.blueAccent,
    this.trailingIcon = Icons.arrow_forward_ios,
    this.trailingIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Icon(trailingIcon,
            size: 16, color: trailingIconColor ?? Colors.grey),
        onTap: onTap,
      ),
    );
  }
}