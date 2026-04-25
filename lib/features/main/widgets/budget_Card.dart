import 'package:flutter/material.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 220,
      width: 400,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // 🔹 Top Shape
            Positioned(
              top: -60,
              left: -80,
              child: Image.asset(
                "assets/images/shape_upper.png",
                width: 300,
                fit: BoxFit.cover,
              ),
            ),

            // 🔹 Bottom Shape
            Positioned(
              bottom: -100,
              left: -20,
              child: Image.asset(
                "assets/images/shape_down.png",
                width: 300,
                fit: BoxFit.cover,
              ),
            ),

            // 🔹 Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Remaining Budget",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "\$132,000.00",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Income",
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          Text(
                            "\$1000000",
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "Expenses",
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          Text(
                            "\$100000",
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
