enum AppRoute {
  // Main navigation routes
  home(path: '/', name: 'home'),
  scanner(path: '/scanner', name: 'scanner'),
  calendar(path: '/calendar', name: 'calendar'),
  profile(path: '/profile', name: 'profile'),

  // Ticket related routes
  ticketView(path: '/ticket', name: 'ticketView'),

  // Scanner related routes
  barcodeScanner(path: '/barcode-scanner', name: 'barcodeScanner'),

  // Export functionality
  export(path: '/export', name: 'export'),

  // Settings and configuration
  settings(path: '/settings', name: 'settings'),

  // Debug routes
  dbViewer(path: '/db-viewer', name: 'dbViewer');

  const AppRoute({required this.path, required this.name});

  final String path;
  final String name;
}
