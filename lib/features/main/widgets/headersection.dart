import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class Headersection extends StatelessWidget {
  const Headersection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Color(0x30265685),
          ),

          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 2),
            child: Row(
              children: [
                SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: Color(0x30265685),
                  child: SvgPicture.asset('assets/icons/User_avatar.svg'),
                ),
                SizedBox(width: 28),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hello, Ahmed!"),
                    Text("Lets save your money"),
                  ],
                ),
              ],
            ),
          ),
        ),
        Spacer(),
        GestureDetector(
          onTap: () => context.push('/chatbot'),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Color(0x40265685),
            child: Icon(Icons.auto_awesome, color: Colors.amber),
          ),
        ),
        SizedBox(width: 20),
        CircleAvatar(
          radius: 20,
          backgroundColor: Color(0x40265685),
          child: Icon(Icons.document_scanner_outlined, color: Colors.white),
        ),
      ],
    );
  }
}
