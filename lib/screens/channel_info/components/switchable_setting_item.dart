import 'package:flutter/material.dart';
import 'package:sendbird_flutter/screens/channel_info/components/setting_item.dart';
import 'package:sendbird_flutter/styles/text_style.dart';

class SwitchableSettingItem extends SettingItem {
  final bool isOn;
  final Function(bool) onChanged;

  SwitchableSettingItem({
    required String name,
    required String iconImageName,
    required Size iconSize,
    required Color iconColor,
    required double height,
    required this.isOn,
    required this.onChanged,
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
      children: [Switch.adaptive(value: isOn, onChanged: onChanged)],
    ));
  }
}
