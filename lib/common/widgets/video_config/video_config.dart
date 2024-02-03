import 'package:flutter/material.dart';

class VideoConfig extends InheritedWidget {
  const VideoConfig({
    super.key,
    required super.child,
  });

  // 自動靜音
  final bool autoMute = false;

  static VideoConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<VideoConfig>()!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}
