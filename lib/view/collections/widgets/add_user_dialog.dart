import 'package:flutter/material.dart';

class AddUserDialog extends StatefulWidget {
  final String collectionId;
  final void Function(String userId) onAddUser;

  const AddUserDialog({
    Key? key,
    required this.collectionId,
    required this.onAddUser,
  }) : super(key: key);

  @override
  State createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final TextEditingController _userIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add User ID"),
      content: TextField(
        controller: _userIdController,
        decoration: const InputDecoration(hintText: "Enter User ID"),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("Add"),
          onPressed: () {
            final userId = _userIdController.text;
            widget.onAddUser(userId);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
