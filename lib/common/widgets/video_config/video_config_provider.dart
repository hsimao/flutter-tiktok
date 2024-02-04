import 'package:flutter/material.dart';

class VideoConfigProvider extends ChangeNotifier {
  bool isMuted = false;
  bool isAutoplay = false;
  bool isDarkMode = false;

  void toggleIsMuted() {
    isMuted = !isMuted;
    notifyListeners();
  }

  void toggleIsAutoplay() {
    isAutoplay = !isAutoplay;
    notifyListeners();
  }
}
