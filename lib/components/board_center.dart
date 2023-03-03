import 'package:flutter/material.dart';
import 'package:batball/extensions/extensions.dart';

class BoardCenter extends StatelessWidget {
  final int diameter;
  const BoardCenter({super.key, required this.diameter});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: diameter.toDouble(),
      width: diameter.toDouble(),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(
              width: 5,
              color: context.isDarkMode ? Colors.white : Colors.black)),
    );
  }
}
