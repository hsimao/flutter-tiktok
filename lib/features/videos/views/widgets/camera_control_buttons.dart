import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tiktok_clone/features/videos/views/widgets/camera_icon_button.dart';

final List<dynamic> flashIcons = [
  {
    "flashMode": FlashMode.off,
    "icon": Icons.flash_off_rounded,
  },
  {
    "flashMode": FlashMode.always,
    "icon": Icons.flash_on_rounded,
  },
  {
    "flashMode": FlashMode.auto,
    "icon": Icons.flash_auto_rounded,
  },
  {
    "flashMode": FlashMode.torch,
    "icon": Icons.flashlight_on_rounded,
  },
];

class CameraControlButtons extends StatelessWidget {
  final FlashMode flashMode;
  final void Function(FlashMode flashMode) setFlashMode;
  final void Function() toggleSelfieMode;

  const CameraControlButtons({
    super.key,
    required this.flashMode,
    required this.setFlashMode,
    required this.toggleSelfieMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CameraIconButton(
          onPressed: toggleSelfieMode,
          icon: Icons.cameraswitch,
        ),
        for (var flashIcon in flashIcons)
          CameraIconButton(
            isSelect: flashMode == flashIcon["flashMode"],
            onPressed: () => setFlashMode(flashIcon["flashMode"]),
            icon: flashIcon['icon'],
          )
      ],
    );
  }
}
