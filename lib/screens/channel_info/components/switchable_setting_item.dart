import 'package:flutter/material.dart';
import 'package:sendbird_flutter/styles/text_style.dart';

import 'setting_item.dart';

class SwitchableSettingItem extends SettingItem {
  final bool isOn;
  final Function(bool) onChanged;

  SwitchableSettingItem({
    String name,
    String iconImageName,
    Size iconSize,
    Color iconColor,
    double height,
    this.isOn,
    this.onChanged,
  }) : super(
          name: name,
          iconImageName: iconImageName,
          iconSize: iconSize,
          iconColor: iconColor,
          height: height,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildLeft(),
          _buildRight(),
        ],
      ),
    );
  }

  _buildLeft() {
    return Expanded(
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
    );
  }

  _buildRight() {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [Switch(value: isOn, onChanged: onChanged)],
    ));
  }
}
