import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../get_controllers/home_controller.dart';

class GeneratingQuestionsProgressIndicator extends StatelessWidget {
  GeneratingQuestionsProgressIndicator({
    super.key,
  });

  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.generatingResponse.value
        ? const Row(
            children: [
              Text(
                'Generating MCQs with Google Gemini AI',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                width: 16,
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ],
          )
        : Container());
  }
}
