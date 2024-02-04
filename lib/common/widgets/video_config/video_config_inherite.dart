import 'package:flutter/material.dart';

class VideoConfigInheriteData extends InheritedWidget {
  final bool autoMute;

  final void Function() toggleMuted;

  const VideoConfigInheriteData({
    super.key,
    required super.child,
    required this.autoMute,
    required this.toggleMuted,
  });

  static VideoConfigInheriteData of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<VideoConfigInheriteData>()!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}

class VideoConfigInherite extends StatefulWidget {
  final Widget child;

  const VideoConfigInherite({
    super.key,
    required this.child,
  });

  @override
  State<VideoConfigInherite> createState() => _VideoConfigInheriteState();
}

class _VideoConfigInheriteState extends State<VideoConfigInherite> {
  // 自動靜音
  bool autoMute = true;

  void toggleMuted() {
    setState(() {
      autoMute = !autoMute;
    });
  }

  @override
  Widget build(BuildContext context) {
    return VideoConfigInheriteData(
      toggleMuted: toggleMuted,
      autoMute: autoMute,
      child: widget.child,
    );
  }
}
