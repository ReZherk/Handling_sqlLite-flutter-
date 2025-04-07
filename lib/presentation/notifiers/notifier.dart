import 'package:flutter/widgets.dart';

class CartNotifier extends ChangeNotifier {
  void shouldRefresh() {
    notifyListeners();
  }
}
