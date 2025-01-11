import 'package:flutter/material.dart';

class Boxed extends StatelessWidget {
  const Boxed({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: Colors.grey, width: 1, style: BorderStyle.solid)),
      child: child,
    );
  }
}
