import 'package:flutter/material.dart';

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
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(4),
        child: ToggleButtons(
          isSelected: [
            selectedFilter == 0,
            selectedFilter == 1,
            selectedFilter == 2,
          ],
          onPressed: onFilterChanged,
          borderRadius: BorderRadius.circular(20),
          selectedColor: Theme.of(context).colorScheme.onPrimary,
          fillColor: Theme.of(context).colorScheme.primary,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          renderBorder: false,
          constraints: const BoxConstraints(minHeight: 40, minWidth: 80),
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Week',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Month',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Range',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
