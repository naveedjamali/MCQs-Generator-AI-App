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
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Obx(() => controller.generatingResponse.value
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMobile)
                const Text(
                  'Generating MCQs with Google Gemini AI',
                  style: TextStyle(color: Colors.white),
                ),
              if (!isMobile)
                const SizedBox(
                  width: 16,
                ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ],
          )
        : Container());
  }
}
