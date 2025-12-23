import 'package:flutter/foundation.dart';

class AnimatedFABProvider extends ChangeNotifier {
  bool _isExtended = false;

  bool get isExtended => _isExtended;

  void toggleExtension() {
    _isExtended = !_isExtended;
    notifyListeners();
  }

  void reset() {
    _isExtended = false;
    notifyListeners();
  }
}
