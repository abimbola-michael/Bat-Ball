import 'package:flutter/material.dart';

class Bat extends StatelessWidget {
  final int width, height;
  final Color color;
  const Bat({super.key, required this.height, required this.width, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.toDouble(),
      width: width.toDouble(),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(10)),
    );
  }
}
