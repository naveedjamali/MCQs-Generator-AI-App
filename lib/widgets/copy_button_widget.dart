import 'package:flutter/material.dart';

class CopyButtonWidget extends StatelessWidget {
  CopyButtonWidget({super.key, required this.callBack, required this.label});

  final Function() callBack;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        width: 120,
        height: 40,
        child: MaterialButton(
          // icon: const Icon(Icons.copy, color: Colors.green,),
          onPressed: callBack,
          color: Colors.green,
          child: Row(
            children: [
              const Icon(
                Icons.copy,
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
