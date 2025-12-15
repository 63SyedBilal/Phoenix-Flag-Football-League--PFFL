import 'package:flutter/foundation.dart';

class StatKeeperNavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  String get selectedPageTitle {
    switch (_selectedIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Games';
      case 2:
        return 'Add';
      case 3:
        return 'Stats';
      case 4:
        return 'Settings';
      default:
        return 'Home';
    }
  }
}