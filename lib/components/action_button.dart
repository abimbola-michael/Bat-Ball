import 'package:batball/styles/colors.dart';
import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  //final double padding;
  final double height;
  final Color? textColor, color;
  const ActionButton(this.text,
      {super.key, required this.onPressed, required this.height, this.textColor, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
            color: color??appColor, borderRadius: BorderRadius.circular(20)),
        alignment: Alignment.center,
        height: height,
        width: double.infinity,
        child: Text(
          text,
          style: TextStyle(color: textColor ??Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
