import 'package:flutter/material.dart';

class InfoCardModel {
  final String title;
  final IconData icon;
  final String subtitle1;
  final String? subtitle2;
  final Color iconColor;
  final Color iconBgColor;

  InfoCardModel({
    required this.title,
    required this.icon,
    required this.subtitle1,
    this.subtitle2,
    required this.iconColor,
    required this.iconBgColor,
  });
}
