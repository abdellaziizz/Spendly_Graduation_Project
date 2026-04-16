import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Headsection extends StatelessWidget {
  const Headsection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color(0xffFFFFFF),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Color(0xff397BBD),
            child: SvgPicture.asset(
              'assets/icons/User_avatar.svg',
              width: 40,
              height: 40,
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ahmed Mohamed',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              Text(
                'mrRobo999@gmail.com',
                style: TextStyle(color: Color(0xff7F879E), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
