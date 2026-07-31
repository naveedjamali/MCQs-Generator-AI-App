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
        ? Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.4),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    controller.loadingMessage.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                const SizedBox(width: 6),
                const SizedBox(
                  width: 12,
                  height: 14,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink());
  }
}
