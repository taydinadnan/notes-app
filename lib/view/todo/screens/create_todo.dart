import 'package:flutter/material.dart';
import 'package:notes_app/repository/todo_repository.dart';

class CreateToDoPage extends StatefulWidget {
  final ToDoRepository todoRepository;

  const CreateToDoPage({super.key, required this.todoRepository});

  @override
  State createState() => _CreateToDoPageState();
}

class _CreateToDoPageState extends State<CreateToDoPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _todoItemController = TextEditingController();
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

      // Use your repository to add the to-do
      await widget.todoRepository.addToDo(title, description, todoList);

      // Navigate back to the previous screen or perform other actions as needed
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create To-Do'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a title.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              const Text('To-Do Items:'),
              Column(
                children: todoList.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final String todoItem = entry.value;
                  return ListTile(
                    title: Text(todoItem),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeTodoItem(index),
                    ),
                  );
                }).toList(),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _todoItemController,
                      decoration:
                          const InputDecoration(labelText: 'Add To-Do Item'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addTodoItem,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitToDo,
                child: const Text('Create To-Do'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
