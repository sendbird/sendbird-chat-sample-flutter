import 'package:app/color.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget featureItem(String title, Function()? onTap, {Icon? icon}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Card(
      child: ListTile(
        onTap: onTap,
        leading: icon ??
            const FaIcon(
              FontAwesomeIcons.solidStar,
              color: sendbirdColor,
            ),
        title: Text(
          title,
          style: const TextStyle(
            color: sendbirdColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}
