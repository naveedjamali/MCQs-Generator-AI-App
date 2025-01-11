import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_controllers/home_controller.dart';

class SearchButton extends StatelessWidget {
  SearchButton({
    super.key,
  });
  final AppController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(() => IconButton(
        onPressed: () {
          if (!controller.getSearchMode()) {
            if (controller.searchController.text.trim().isNotEmpty) {
              controller.setSearchMode(true);
              controller.queryText.value = controller.searchController.text;
            }
          } else {
            controller.searchController.text = '';
            controller.setSearchMode(false);
          }
        },
        icon: controller.getSearchMode()
            ? const Icon(
                Icons.close,
                color: Colors.red,
              )
            : const Icon(
                Icons.search,
                color: Colors.grey,
              )));
  }
}
