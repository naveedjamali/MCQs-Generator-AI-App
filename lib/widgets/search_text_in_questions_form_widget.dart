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
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.searchController,
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  labelText: 'Filter questions with word',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SearchButton(),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _filterChip('Text'),
              _filterChip('Essay'),
              _filterChip('Passage'),
              _filterChip('Conclusion'),
              _filterChip('Focus'),
              _filterChip('Idea'),
              _filterChip('Research'),
              _filterChip('World'),
              _filterChip('Earth'),
              _filterChip('France'),
              _filterChip('Planet'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onPressed: () => controller.setSearchText(label.toLowerCase()),
        backgroundColor: Colors.green.withOpacity(0.1),
      ),
    );
  }
}
