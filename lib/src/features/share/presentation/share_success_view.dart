import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';

/// Success screen displayed when data is successfully shared to the application
class ShareSuccessView extends StatelessWidget {
  const ShareSuccessView({
    required this.pnrNumber,
    required this.from,
    required this.to,
    required this.fare,
    required this.date,
    super.key,
  });

  final String pnrNumber;
  final String from;
  final String to;
  final String fare;
  final String date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : AppColor.specialColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 32),

              // Success Title
              Text(
                'Ticket Added Successfully!',
                style: HeadingH3(color: theme.colorScheme.onSurface).bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Success Message
              Text(
                'Your ticket has been saved to your wallet',
                style: Paragraph02(color: theme.colorScheme.onSurface.withOpacity(0.7)).regular,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Ticket Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PNR Number
                    _DetailRow(
                      label: 'PNR Number',
                      value: pnrNumber,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),

                    // Route
                    _DetailRow(
                      label: 'Route',
                      value: '$from → $to',
                      theme: theme,
                    ),
                    const SizedBox(height: 16),

                    // Journey Date
                    _DetailRow(
                      label: 'Journey Date',
                      value: date,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),

                    // Fare
                    _DetailRow(
                      label: 'Total Fare',
                      value: fare,
                      theme: theme,
                      isHighlighted: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Column(
                children: [
                  // View Ticket Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go(AppRoute.home.path);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'View My Tickets',
                        style: Paragraph01(color: Colors.white).semiBold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: TextButton(
                      onPressed: () {
                        context.go(AppRoute.home.path);
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Done',
                        style: Paragraph01(color: AppColor.primaryBlue).semiBold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.theme,
    this.isHighlighted = false,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Paragraph03(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ).regular,
        ),
        Text(
          value,
          style: isHighlighted
              ? Paragraph02(color: AppColor.primaryBlue).semiBold
              : Paragraph02(color: theme.colorScheme.onSurface).semiBold,
        ),
      ],
    );
  }
}
