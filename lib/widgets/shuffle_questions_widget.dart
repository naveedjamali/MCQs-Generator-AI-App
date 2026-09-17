import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../get_controllers/home_controller.dart';

class ShuffleQuestionsWidget extends StatelessWidget {
  ShuffleQuestionsWidget({
    super.key,
    this.isAppBar = false,
  });

  final bool isAppBar;
  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final color = isAppBar ? Colors.white : Colors.blueGrey.shade700;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: TextButton.icon(
        onPressed: () {
          controller.questions.shuffle();
        },
        icon: Icon(Icons.shuffle, size: 18, color: color),
        label: Text('Shuffle', style: TextStyle(color: color, fontSize: 13)),
        style: TextButton.styleFrom(
          foregroundColor: color,
        ),
      ),
    );
  }
}
