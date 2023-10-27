import 'package:flutter/material.dart';
import 'package:notes_app/app_style.dart';

Widget buildTextField(
    TextEditingController controller, String title, bool? obscureText) {
  return Card(
    elevation: 4,
    color: AppStyle.white,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText ?? false,
        decoration: InputDecoration(
            border: InputBorder.none,
            labelStyle: AppStyle.mainTitle,
            labelText: title),
        style: AppStyle.mainTitle,
      ),
    ),
  );
}

Widget buildErrorMessage(String? errorMessage) =>
    Text(errorMessage == '' ? '' : 'Hmmm ? $errorMessage');
