import 'package:flutter/material.dart';

Widget buildTextField(
    TextEditingController controller, String title, bool? obscureText) {
  return TextField(
    controller: controller,
    obscureText: obscureText ?? false,
    decoration: InputDecoration(
      labelText: title,
    ),
  );
}

Widget buildErrorMessage(String? errorMessage) =>
    Text(errorMessage == '' ? '' : 'Hmmm ? $errorMessage');
