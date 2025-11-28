import 'package:flutter/foundation.dart';

class AIServiceStatus extends ChangeNotifier {
  bool _isGemmaSupported = true;
  bool get isGemmaSupported => _isGemmaSupported;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setGemmaSupport(bool supported, {String? error}) {
    _isGemmaSupported = supported;
    _errorMessage = error;
    notifyListeners();
  }
}
