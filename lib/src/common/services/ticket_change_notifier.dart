import 'package:flutter/foundation.dart';

class TicketChangeNotifier extends ChangeNotifier {
  void notifyTicketChanged() {
    notifyListeners();
  }
}
