import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';

/// A card widget for displaying an import method option.
///
/// This widget provides a visually consistent card with an icon, title,
/// optional subtitle, and loading state support. It's designed to be used
/// in a grid layout for import method selection.
class ImportMethodCardWidget extends StatelessWidget {
  const ImportMethodCardWidget({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.isLoading = false,
    this.backgroundColor,
    super.key,
  });

  /// The icon to display at the top of the card
  final IconData icon;

  /// The main title of the import method
  final String title;

  /// Optional subtitle providing additional context
  final String? subtitle;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Whether the card is in a loading state
  final bool isLoading;

  /// Optional background color for the card (defaults to theme surface color)
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = backgroundColor ?? theme.colorScheme.surface;

    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: (isLoading || onTap == null) ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 52,
                      color: backgroundColor != null
                          ? Colors.white
                          : primaryColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: Paragraph02(
                        color: backgroundColor != null
                            ? Colors.white
                            : textColor,
                      ).semiBold,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Caption(
                          color: backgroundColor != null
                              ? Colors.white.withAlpha(204)
                              : textColor.withAlpha(153),
                        ).regular,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Loading overlay
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(51),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: backgroundColor != null
                            ? Colors.white
                            : primaryColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
