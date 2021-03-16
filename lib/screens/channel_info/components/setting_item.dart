import 'package:flutter/material.dart';
import 'package:sendbird_flutter/styles/color.dart';
import 'package:sendbird_flutter/styles/text_style.dart';

enum SettingType {
  none,
  switchable,
  detail,
}

class SettingItem extends StatelessWidget {
  final String name;
  final String iconImageName;
  final Size iconSize;
  final Color iconColor;
  final Function onTap;
  final double height;

  SettingItem({
    this.name,
    this.iconImageName,
    this.iconColor,
    this.iconSize = const Size(20, 20),
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildIcon(
              imageName: iconImageName,
              color: iconColor,
              iconSize: iconSize,
            ),
            SizedBox(width: 16),
            Text(name, style: TextStyles.sendbirdBody1OnLight1),
          ],
        ),
      ),
      onTap: this.onTap,
    );
  }
}

buildIcon({
  String imageName,
  Color color = SBColors.primary_300,
  Size iconSize,
}) {
  return Container(
    height: iconSize.height,
    width: iconSize.width,
    child: ImageIcon(
      AssetImage(imageName),
      color: color,
    ),
  );
}
