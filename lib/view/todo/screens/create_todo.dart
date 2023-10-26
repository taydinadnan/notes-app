import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/app_spacing.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/repository/todo_repository.dart';
import 'package:notes_app/view/todo/widgets/todo_title_desc_card.dart';

class CreateToDoPage extends StatefulWidget {
  final ToDoRepository todoRepository;

  const CreateToDoPage({
    super.key,
    required this.todoRepository,
  });

  @override
  State createState() => _CreateToDoPageState();
}

class _CreateToDoPageState extends State<CreateToDoPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _todoItemController = TextEditingController();
  String date = DateFormat("dd/MMM/yyyy - HH:mm").format(DateTime.now());
  List<String> todoList = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _todoItemController.dispose();
    super.dispose();
  }

  void _addTodoItem() {
    final String todoItem = _todoItemController.text.trim();
    if (todoItem.isNotEmpty) {
      setState(() {
        todoList.add(todoItem);
        _todoItemController.clear();
      });
    }
  }

  void _removeTodoItem(int index) {
    setState(() {
      todoList.removeAt(index);
    });
  }

  Future<void> _submitToDo() async {
    if (_formKey.currentState!.validate()) {
      final String title = _titleController.text;
      final String description = _descriptionController.text;

      if (todoList.isEmpty) {
        // Show an error message if there are no to-do items.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one to-do item.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        await widget.todoRepository.addToDo(title, description, todoList);
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFbfe7f6),
      appBar: buildAppBar(),
      body: buildBody(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Create To-Do',
            style: AppStyle.mainTitle,
          ),
          Text(date, style: AppStyle.dateTitle),
        ],
      ),
      backgroundColor: const Color(0xFFbfe7f6),
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTitleAndDescription(),
              spacingMedium,
              Text('To-Do Items:', style: AppStyle.mainTitle),
              buildTodoList(),
              buildAddTodoItemInput(),
              spacingMedium,
              buildCreateToDoButton(),
            ],
          ),
        ),
      ),
    );
  }

  Column buildTitleAndDescription() {
    return Column(
      children: [
        TodoTitleDescriptionCard(
          titleController: _titleController,
          descriptionController: _descriptionController,
        ),
      ],
    );
  }

  Column buildTodoList() {
    return Column(
      children: todoList.asMap().entries.map((entry) {
        final int index = entry.key;
        final String todoItem = entry.value;
        return Card(
          elevation: 4,
          color: AppStyle.white,
          child: ListTile(
            title: Text(todoItem),
            titleTextStyle: AppStyle.mainContent,
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeTodoItem(index),
            ),
          ),
        );
      }).toList(),
    );
  }

  Card buildAddTodoItemInput() {
    return Card(
      elevation: 4,
      color: AppStyle.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelStyle: AppStyle.mainContent,
                  label: const Text("Add To-Do Item"),
                ),
                textInputAction: TextInputAction.go,
                onEditingComplete: _addTodoItem,
                style: AppStyle.mainContent,
                controller: _todoItemController,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addTodoItem,
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton buildCreateToDoButton() {
    return ElevatedButton(
      onPressed: _submitToDo,
      child: const Text('Create To-Do'),
    );
  }
}
