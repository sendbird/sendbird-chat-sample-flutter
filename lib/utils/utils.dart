import 'package:flutter/material.dart';

void showLoader(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          width: 100,
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    },
  );
}
