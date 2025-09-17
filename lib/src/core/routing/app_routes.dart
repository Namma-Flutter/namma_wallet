enum AppRoute {
  // Main navigation routes
  home(path: '/', name: 'home'),
  scanner(path: '/scanner', name: 'scanner'),
  calendar(path: '/calendar', name: 'calendar'),
  profile(path: '/profile', name: 'profile'),

  // Ticket related routes
  ticketView(path: '/ticket', name: 'ticketView'),
  ticketDetails(path: '/ticket/:id', name: 'ticketDetails'),

  // Export functionality
  export(path: '/export', name: 'export'),

  // TNSTC specific
  tnstcTicket(path: '/tnstc-ticket', name: 'tnstcTicket'),

  // Settings and configuration
  settings(path: '/settings', name: 'settings');

  const AppRoute({required this.path, required this.name});

  final String path;
  final String name;
}
