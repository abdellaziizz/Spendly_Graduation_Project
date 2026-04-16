import 'package:flutter/material.dart';

class ContainerWidget extends StatelessWidget {
  ContainerWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
        color: Color(0xffFFFFFF),
      ),
      height: 55,
      child: Row(
        children: [
          Icon(icon),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Spacer(),
          subtitle != null
              ? Text(subtitle!, style: TextStyle(color: Color(0xff757575)))
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
