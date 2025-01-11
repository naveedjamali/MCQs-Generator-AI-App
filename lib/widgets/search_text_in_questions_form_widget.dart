import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcqs_generator_ai_app/get_controllers/home_controller.dart';
import 'package:mcqs_generator_ai_app/widgets/search_button.dart';

class SearchTextInQuestionsForm extends StatelessWidget {
  SearchTextInQuestionsForm({
    super.key,
  });

  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: TextFormField(
                // enabled: controller.searchBoxEnabled.value,
                controller: controller.searchController,
                decoration: const InputDecoration(
                    label: Text('filter questions with word',
                        style: TextStyle(fontSize: 10))),
              )),
          SearchButton(),
        ],
      ),
    );
  }
}
