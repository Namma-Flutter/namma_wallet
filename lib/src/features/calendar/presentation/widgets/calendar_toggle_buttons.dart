import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';

class CalendarToggleButtons extends StatelessWidget {
  const CalendarToggleButtons({
    required this.selectedFilter,
    required this.onFilterChanged,
    super.key,
  });

  final int selectedFilter;
  final void Function(int) onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.periwinkleBlue,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 19,
            ),
          ],
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildToggleButton('Week', selectedFilter == 0, () {
              onFilterChanged(0);
            }),
            _buildToggleButton('Month', selectedFilter == 1, () {
              onFilterChanged(1);
            }),
            _buildToggleButton('Range', selectedFilter == 2, () {
              onFilterChanged(2);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isSelected
                      ? AppColor.periwinkleBlue
                      : Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
