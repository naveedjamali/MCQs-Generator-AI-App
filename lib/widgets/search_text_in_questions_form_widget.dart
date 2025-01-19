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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(
          color: Colors.grey,
          height: 1,
          thickness: 1,
        ),
        const Text(
          'Filter questions with words:',
          style: TextStyle(fontSize: 14),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
                onPressed: () => controller.setSearchText('text'),
                child: const Text('Text')),
            TextButton(
                onPressed: () => controller.setSearchText('essay'),
                child: const Text('Essay')),
            TextButton(
                onPressed: () => controller.setSearchText('passage'),
                child: const Text('Passage')),
            TextButton(
                onPressed: () => controller.setSearchText('conclu'),
                child: const Text('Conclusion')),
            TextButton(
                onPressed: () => controller.setSearchText('focus'),
                child: const Text('Focus')),
            TextButton(
                onPressed: () => controller.setSearchText('idea'),
                child: const Text('Idea')),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
                onPressed: () => controller.setSearchText('research'),
                child: const Text('Research')),
            TextButton(
                onPressed: () => controller.setSearchText('this'),
                child: const Text('This')),
            TextButton(
                onPressed: () => controller.setSearchText('world'),
                child: const Text('World')),
            TextButton(
                onPressed: () => controller.setSearchText('earth'),
                child: const Text('Earth')),
            TextButton(
                onPressed: () => controller.setSearchText('france'),
                child: const Text('France')),
            TextButton(
                onPressed: () => controller.setSearchText('planet'),
                child: const Text('Planet')),
          ],
        ),
        Row(
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
      ],
    );
  }
}
