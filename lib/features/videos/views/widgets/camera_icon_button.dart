import 'package:flutter/material.dart';

class CameraIconButton extends StatelessWidget {
  final IconData icon;
  final bool isSelect;
  final void Function()? onPressed;

  const CameraIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isSelect = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
        color: isSelect ? Colors.amber : Colors.white,
        onPressed: onPressed,
        icon: Icon(icon));
  }
}
