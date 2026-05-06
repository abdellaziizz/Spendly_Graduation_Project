import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wallet_provider.dart';
import '../widgets/track_category_card.dart';
import '../widgets/create_category_sheet.dart';

class TrackTab extends ConsumerWidget {
  const TrackTab({Key? key}) : super(key: key);

  void _showAddCustomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateCategorySheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.85,
          ),
          itemCount: budgets.length + 1, // +1 for "Add custom"
          itemBuilder: (context, index) {
            if (index < budgets.length) {
              return TrackCategoryCard(budget: budgets[index]);
            } else {
              // Add Custom Card
              return _buildAddCustomCard(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildAddCustomCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddCustomSheet(context),
      child: CustomPaint(
        painter: DashedRectPainter(
          color: Colors.blueAccent.withOpacity(0.5),
          strokeWidth: 2.0,
          gap: 5.0,
          radius: 16.0,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.indigo, // Dark blue/purple circle from design
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                'Add custom',
                style: TextStyle(
                  color: Colors.indigo.shade400,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    Path path = Path()..addRRect(rrect);
    PathMetrics pathMetrics = path.computeMetrics();
    Path dashedPath = Path();

    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      bool draw = true;
      while (distance < pathMetric.length) {
        double len = draw ? gap : gap;
        if (draw) {
          dashedPath.addPath(
            pathMetric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
