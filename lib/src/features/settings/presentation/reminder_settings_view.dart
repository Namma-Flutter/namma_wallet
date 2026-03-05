import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/models/reminder_preferences.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/notification/reminder_preferences_service.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';
import 'package:namma_wallet/src/common/widgets/rounded_back_button.dart';
import 'package:namma_wallet/src/common/widgets/snackbar_widget.dart';

/// Settings page for configuring default reminder intervals
class ReminderSettingsView extends StatefulWidget {
  const ReminderSettingsView({super.key});

  @override
  State<ReminderSettingsView> createState() => _ReminderSettingsViewState();
}

class _ReminderSettingsViewState extends State<ReminderSettingsView> {
  late IReminderPreferencesService _preferencesService;
  late ILogger _logger;

  List<int> _selectedIntervals = [];
  bool _isLoading = true;
  bool _isSaving = false;

  // All available hour options (1 to 24)
  static const List<int> _availableHours = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    12,
    24,
  ];

  @override
  void initState() {
    super.initState();
    _preferencesService = getIt<IReminderPreferencesService>();
    _logger = getIt<ILogger>();
    unawaited(_loadPreferences());
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await _preferencesService.getDefaultRemainderPreferences();
      if (mounted) {
        setState(() {
          _selectedIntervals = prefs.selectedIntervals.toList();
          _isLoading = false;
        });
      }
    } on Exception catch (e, st) {
      _logger.error(
        '[ReminderSettingsView] Failed to load preferences',
        e,
        st,
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showSnackbar(
          context,
          'Failed to load preferences: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _savePreferences() async {
    if (_selectedIntervals.isEmpty) {
      showSnackbar(
        context,
        'Please select at least one reminder interval',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final preferences = ReminderPreferences(
        selectedIntervals: _selectedIntervals,
      );
      await _preferencesService.saveDefaultRemainderPreferences(preferences);

      _logger.info(
        '[ReminderSettingsView] Saved reminder preferences: '
        '$_selectedIntervals',
      );

      if (mounted) {
        showSnackbar(context, 'Reminder preferences saved successfully');
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.pop();
          }
        });
      }
    } on Exception catch (e, st) {
      _logger.error(
        '[ReminderSettingsView] Failed to save preferences',
        e,
        st,
      );
      if (mounted) {
        showSnackbar(
          context,
          'Failed to save preferences: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _resetToDefault() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Default?'),
        content: const Text(
          'This will reset reminder intervals to 24hr, 4hr, and 2hr before '
          'journey start time.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && mounted) {
      setState(() {
        _selectedIntervals = ReminderPreferences
            .defaultPreferences
            .selectedIntervals
            .toList();
      });
    }
  }

  void _toggleInterval(int hour) {
    setState(() {
      if (_selectedIntervals.contains(hour)) {
        _selectedIntervals.remove(hour);
      } else {
        _selectedIntervals
          ..add(hour)
          ..sort();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(),
        title: const Text('Reminder Settings'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.notifications_active_outlined,
                                  size: 24,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Default Reminder Intervals',
                                        style: Paragraph01(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ).semiBold,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Select when you want to be reminded '
                                        'before your journey starts',
                                        style: Paragraph03(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.7),
                                        ).regular,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Hour Selection Grid
                    Text(
                      'Select Intervals (Hours)',
                      style: Paragraph01(
                        color: Theme.of(context).colorScheme.onSurface,
                      ).semiBold,
                    ),

                    const SizedBox(height: 12),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                          ),
                      itemCount: _availableHours.length,
                      itemBuilder: (context, index) {
                        final hour = _availableHours[index];
                        final isSelected = _selectedIntervals.contains(hour);

                        return GestureDetector(
                          onTap: () => _toggleInterval(hour),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primary.withValues(alpha: 0.9)
                                  : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface
                                          .withValues(alpha: 0.2),
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$hour',
                                  style: Paragraph01(
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                  ).semiBold,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  hour == 1 ? 'hour' : 'hrs',
                                  style: Paragraph03(
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.6),
                                  ).regular,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Selected Summary
                    if (_selectedIntervals.isNotEmpty)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reminders will be sent at:',
                                style: Paragraph02(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ).semiBold,
                              ),
                              const SizedBox(height: 12),
                              ..._selectedIntervals.map((hour) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 18,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$hour ${hour == 1 ? "hour" : "hours"} '
                                        'before journey start time',
                                        style: Paragraph02(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ).regular,
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Action Buttons
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton(
                          onPressed: _isSaving ? null : _savePreferences,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Save Preferences'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _resetToDefault,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Reset to Default'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}
