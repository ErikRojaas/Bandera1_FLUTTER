import 'package:flutter/foundation.dart';

class TimerProvider with ChangeNotifier {
  String _timer = "00:00";

  String get timer => _timer;

  void updateTimer(String newTimer) {
    if (_timer != newTimer) {
      _timer = newTimer;
      notifyListeners();
    }
  }

  String get formattedTimer => _timer;
} 