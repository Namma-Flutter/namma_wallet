
import 'package:flutter/material.dart';
import 'package:namma_wallet/styles/styles.dart';

class UserProfileWidget extends StatelessWidget {
  const UserProfileWidget({
    super.key,
  });

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
              style: TextStyle(
                  color: AppColor.blackColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),

          //* Profile
          CircleAvatar(
            radius: 28,
            backgroundImage: const NetworkImage(
                'https://avatars.githubusercontent.com/u/583231?v=4'),
            backgroundColor: Colors.grey[200],
          ),
        ],
      ),
    );
  }
}
