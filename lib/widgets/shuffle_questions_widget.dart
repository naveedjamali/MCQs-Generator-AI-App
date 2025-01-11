import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../get_controllers/home_controller.dart';

class ShuffleQuestionsWidget extends StatelessWidget {
  ShuffleQuestionsWidget({
    super.key,
  });

  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: MaterialButton(
        onPressed: () {
          controller.questions.shuffle();
        },
        child: const Row(
          children: [
            Icon(Icons.shuffle),
            Text(' Shuffle Questions'),
          ],
        ),
      ),
    );
  }
}
