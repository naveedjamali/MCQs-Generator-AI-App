import 'package:flutter/material.dart';

class SaveButtonWidget extends StatelessWidget {
  const SaveButtonWidget(
      {super.key, required this.label, required this.onPressed});

  final String label;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        width: 125,
        height: 40,
        child: MaterialButton(
          onPressed: onPressed,
          color: Colors.green,
          child: Row(
            children: [
              const Icon(
                Icons.text_snippet_outlined,
                color: Colors.white,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
