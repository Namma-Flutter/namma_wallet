import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';

class CalendarToggleButtons extends StatelessWidget {
  const CalendarToggleButtons({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final int selectedFilter;
  final void Function(int) onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ToggleButtons(
          isSelected: [
            selectedFilter == 0,
            selectedFilter == 1,
            selectedFilter == 2
          ],
          onPressed: onFilterChanged,
          borderRadius: BorderRadius.circular(16),
          selectedBorderColor: AppColor.periwinkleBlue,
          selectedColor: Colors.white,
          borderWidth: 2,
          fillColor: AppColor.periwinkleBlue,
          color: Colors.grey[700],
          constraints: const BoxConstraints(minHeight: 40, minWidth: 80),
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text('Week',
                  style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text('Month',
                  style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text('Range',
                  style: TextStyle(fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}