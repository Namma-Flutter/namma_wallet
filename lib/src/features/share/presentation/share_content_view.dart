import 'package:flutter/material.dart';

enum ShareContentType { ticket, event, qr, document }

class ShareContentView extends StatefulWidget {
  const ShareContentView({
    required this.onShare,
    super.key,
  });

  final void Function(ShareContentType type, String title) onShare;

  @override
  State<ShareContentView> createState() => _ShareContentViewState();
}

class _ShareContentViewState extends State<ShareContentView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _backdropAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _backdropAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start animation immediately
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleClose() async {
    await _controller.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final shareOptions = [
      const _ShareOption(
        type: ShareContentType.ticket,
        icon: Icons.confirmation_number_outlined,
        title: 'Travel Ticket',
        description: 'Add a train, bus, or flight ticket',
        examples: ['SMS', 'PDF', 'Screenshot'],
      ),
      const _ShareOption(
        type: ShareContentType.event,
        icon: Icons.calendar_today_outlined,
        title: 'Event Pass',
        description: 'Add event or concert tickets',
        examples: ['Email', 'PDF', 'QR Code'],
      ),
      const _ShareOption(
        type: ShareContentType.qr,
        icon: Icons.qr_code_2_outlined,
        title: 'QR Code',
        description: 'Add any QR code ticket',
        examples: ['Image', 'Screenshot'],
      ),
      const _ShareOption(
        type: ShareContentType.document,
        icon: Icons.description_outlined,
        title: 'Document',
        description: 'Add boarding pass or voucher',
        examples: ['PDF', 'Image', 'Text'],
      ),
    ];

    return Stack(
      children: [
        // Animated backdrop
        FadeTransition(
          opacity: _backdropAnimation,
          child: GestureDetector(
            onTap: _handleClose,
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
        ),
        // Animated modal
        SlideTransition(
          position: _slideAnimation,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 393),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F1E7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Share to Wallet',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      letterSpacing: 0.72,
                                      color: Colors.black,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Select content type to add',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontSize: 14,
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                      letterSpacing: 0.42,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Material(
                          color: Colors.black.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            onTap: _handleClose,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.close,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                      child: Column(
                        children: [
                          ...shareOptions.asMap().entries.map(
                                (entry) => _AnimatedShareOptionCard(
                                  option: entry.value,
                                  delay: entry.key * 40,
                                  onTap: () {
                                    widget.onShare(
                                      entry.value.type,
                                      entry.value.title,
                                    );
                                    _handleClose();
                                  },
                                ),
                              ),
                          const SizedBox(height: 8),
                          // Info tip
                          _AnimatedInfoTip(
                            delay: shareOptions.length * 40,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShareOption {
  const _ShareOption({
    required this.type,
    required this.icon,
    required this.title,
    required this.description,
    required this.examples,
  });

  final ShareContentType type;
  final IconData icon;
  final String title;
  final String description;
  final List<String> examples;
}

class _AnimatedShareOptionCard extends StatefulWidget {
  const _AnimatedShareOptionCard({
    required this.option,
    required this.delay,
    required this.onTap,
  });

  final _ShareOption option;
  final int delay;
  final VoidCallback onTap;

  @override
  State<_AnimatedShareOptionCard> createState() =>
      _AnimatedShareOptionCardState();
}

class _AnimatedShareOptionCardState extends State<_AnimatedShareOptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Reduced delay for faster appearance
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AnimatedScale(
            scale: _isPressed ? 0.98 : 1,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isPressed
                              ? const Color(0xFFD5E851)
                              : const Color(0xFFE7FC55),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          widget.option.icon,
                          size: 24,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.option.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    letterSpacing: 0.48,
                                    color: Colors.black,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.option.description,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontSize: 14,
                                    color: Colors.black.withValues(alpha: 0.6),
                                    letterSpacing: 0.42,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: widget.option.examples
                                  .map(
                                    (example) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        example,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontSize: 12,
                                              color: Colors.black.withValues(
                                                alpha: 0.6,
                                              ),
                                              letterSpacing: 0.36,
                                            ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedInfoTip extends StatefulWidget {
  const _AnimatedInfoTip({required this.delay});

  final int delay;

  @override
  State<_AnimatedInfoTip> createState() => _AnimatedInfoTipState();
}

class _AnimatedInfoTipState extends State<_AnimatedInfoTip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE7FC55).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '💡 Tip: SMS ticket sharing is supported today. Support for '
            'camera, email, PDF and clipboard imports is coming soon.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: Colors.black.withValues(alpha: 0.7),
                  letterSpacing: 0.42,
                ),
          ),
        ),
      ),
    );
  }
}

// Helper function to show the modal
void showShareContentModal(
  BuildContext context, {
  required void Function(ShareContentType type, String title) onShare,
}) {
  showGeneralDialog(
    context: context,
    barrierLabel: '',
    transitionDuration: Duration.zero,
    pageBuilder: (context, animation, secondaryAnimation) {
      return ShareContentView(onShare: onShare);
    },
  );
}
