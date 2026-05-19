import 'package:flutter/material.dart';

// Tips and Recommendation and Alerts
class ActionList extends StatelessWidget {
  const ActionList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                height: 100,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B24),
                  border: Border.all(color: Colors.white12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xffC3C0FF).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.lightbulb_outline_rounded,
                            color: Color(0xffC3C0FF),
                            size: 22,
                          ),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            item,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class AlertList extends StatelessWidget {
  const AlertList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                height: 100,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFBA1A1A),
                  border: Border.all(color: Colors.white12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xffFFFFFF).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xffFFFFFF),
                            size: 22,
                          ),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            item,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
