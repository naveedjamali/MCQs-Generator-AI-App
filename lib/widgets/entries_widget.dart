import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../get_controllers/home_controller.dart';

class EntriesWidget extends StatelessWidget {
  EntriesWidget({
    super.key,
  });

  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
          itemCount: controller.entries.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: SelectableText(
                controller.entries[index],
              ),
            );
          },
        ));
  }
}
