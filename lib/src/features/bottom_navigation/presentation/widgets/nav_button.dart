import 'package:flutter/material.dart';

class NavButton extends StatefulWidget {
  const NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<NavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _pressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _pressController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _pressAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pressAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubicEmphasized,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: EdgeInsets.symmetric(
                horizontal: widget.selected ? 14 : 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: widget.selected
                    ? (isDark
                        ? Colors.white.withOpacity(0.15)
                        : Colors.black.withOpacity(0.25))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: widget.selected
                    ? [
                        BoxShadow(
                          color: (isDark ? Colors.white : Colors.black)
                              .withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with smooth scale transition
                  AnimatedScale(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOutCubicEmphasized,
                    scale: widget.selected ? 1.1 : 1.0,
                    child: Icon(
                      widget.icon,
                      size: 22,
                      color: widget.selected
                          ? (isDark ? Colors.white : Colors.white)
                          : (isDark
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.6)),
                    ),
                  ),

                  // Label - only show when selected with smooth animation
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOutCubicEmphasized,
                    child: widget.selected
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOutCubicEmphasized,
                              opacity: widget.selected ? 1.0 : 0.0,
                              child: Text(
                                widget.label,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
