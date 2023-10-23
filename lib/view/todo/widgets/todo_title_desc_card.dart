import 'package:flutter/material.dart';
import 'package:notes_app/app_style.dart';

class TodoTitleDescriptionCard extends StatelessWidget {
  const TodoTitleDescriptionCard({
    super.key,
    this.titleController,
    this.descriptionController,
  });

  final TextEditingController? titleController;
  final TextEditingController? descriptionController;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: AppStyle.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelStyle: AppStyle.mainTitle,
                label: const Text("Title*:"),
              ),
              style: AppStyle.mainTitle,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a title.';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                border: InputBorder.none,
                labelStyle: AppStyle.mainContent,
                label: const Text("Description:"),
              ),
              style: AppStyle.mainContent,
              controller: descriptionController,
            ),
          ],
        ),
      ),
    );
  }
}
