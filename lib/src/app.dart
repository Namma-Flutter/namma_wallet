import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/helper/check_pnr_id.dart';
import 'package:namma_wallet/src/common/routing/app_router.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/common/services/sharing_intent_service.dart';
import 'package:namma_wallet/src/common/theme/app_theme.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';
import 'package:namma_wallet/src/common/theme/theme_provider.dart';
import 'package:namma_wallet/src/features/share/application/share_handler_service.dart';
import 'package:namma_wallet/src/features/share/presentation/share_content_view.dart';
import 'package:namma_wallet/src/features/tnstc/application/sms_service.dart';
import 'package:provider/provider.dart';

class NammaWalletApp extends StatefulWidget {
  const NammaWalletApp({super.key});

  @override
  State<NammaWalletApp> createState() => _NammaWalletAppState();
}

class _NammaWalletAppState extends State<NammaWalletApp> {
  int currentPageIndex = 0;
  late final SharingIntentService _sharingService =
      getIt<SharingIntentService>();
  late final ShareHandlerService _shareHandler =
      ShareHandlerService(logger: getIt<ILogger>());
  late final SMSService _smsService = getIt<SMSService>();
  late final ILogger _logger = getIt<ILogger>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  // Queue for pending share intents
  final List<String> _pendingShares = [];
  bool _isProcessingShare = false;

  @override
  void initState() {
    super.initState();
    _logger.info('App initialized');

    // Wait for first frame before processing shares
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processPendingShares();
    });

    // Initialize sharing intent service with animated modal
    _sharingService.initialize(
      onFileReceived: (filePath) async {
        _logger.info('Share intent received: $filePath');
        
        // Add to queue
        _pendingShares.add(filePath);
        
        // Process immediately if context is available
        if (_navigatorKey.currentContext != null && !_isProcessingShare) {
          await _processPendingShares();
        }
      },
      onError: (error) {
        _logger.error('Sharing intent error: $error');
        if (mounted) {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Unable to share. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      },
    );
  }

  Future<void> _processPendingShares() async {
    if (_pendingShares.isEmpty || _isProcessingShare) return;
    
    _isProcessingShare = true;
    
    try {
      while (_pendingShares.isNotEmpty) {
        final filePath = _pendingShares.removeAt(0);
        
        try {
          _logger.info('Processing shared file: $filePath');
          
          // Process the shared file
          final sharedContent = await _shareHandler.processSharedFile(filePath);
          
          // Show animated modal
          final context = _navigatorKey.currentContext;
          if (context != null && mounted) {
            await _shareHandler.handleSharedContent(
              context: context,
              content: sharedContent,
              onContentProcessed: (type, content) async {
                await _processSharedContent(type, content);
              },
            );
          }
        } on Object catch (e, stackTrace) {
          _logger.error(
            'Error processing shared file',
            e,
            stackTrace,
          );
          if (mounted) {
            _scaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(
                content: Text('Error processing shared file'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
          }
        }
      }
    } finally {
      _isProcessingShare = false;
    }
  }

  Future<void> _processSharedContent(
    ShareContentType type,
    SharedContent content,
  ) async {
    try {
      _logger.info('Processing content as: ${type.name}');

      // Handle based on user-selected type
      if (type == ShareContentType.ticket && content.type == SharedContentType.text) {
        // Process SMS text as ticket
        final ticket = _smsService.parseTicket(content.data);
        await checkAndUpdateTNSTCTicket(ticket);

        _logger.success(
          'Shared SMS processed successfully for PNR: ${ticket.pnrNumber}',
        );
        if (mounted) {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(
                'Ticket added successfully! PNR: ${ticket.pnrNumber}',
              ),
              backgroundColor: AppColor.primaryBlue,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else if (type == ShareContentType.document || content.type == SharedContentType.pdf) {
        // Handle PDF processing
        _logger.info('PDF processing not yet implemented');
        if (mounted) {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('PDF processing coming soon!'),
              backgroundColor: AppColor.primaryBlue,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        _logger.info('Content type ${type.name} not yet supported');
        if (mounted) {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text('${type.name} processing coming soon!'),
              backgroundColor: AppColor.primaryBlue,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } on Object catch (e, stackTrace) {
      _logger.error('Error processing shared content', e, stackTrace);
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Error processing content'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _logger.info('App disposing');
    _sharingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      title: 'NammaWallet',
      theme: AppTheme.lightTheme.copyWith(
        // Set page transitions to be instant for share intents
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      builder: (context, child) {
        // Wrap in a colored container to prevent white flash
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Navigator(
            key: _navigatorKey,
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (context) => child!,
            ),
          ),
        );
      },
    );
  }
}
