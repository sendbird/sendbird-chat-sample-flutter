import 'package:app/color.dart';
import 'package:flutter/material.dart';

Widget textfieldItem(String title, TextEditingController controller) {
  return TextField(
    decoration: InputDecoration(
      hintText: title,
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          width: 3,
          color: sendbirdColor,
        ),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          width: 3,
          color: sendbirdColor,
        ),
      ),
    ),
    controller: controller,
  );
}
