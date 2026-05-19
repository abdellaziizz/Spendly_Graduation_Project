import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class GenerateReportCard extends StatelessWidget {
  const GenerateReportCard({
    super.key,
    required this.onGenerate,
    required this.reportError,
    required this.generatedReport,
  });
  final VoidCallback onGenerate;
  final String? reportError;
  final Map<String, dynamic>? generatedReport;
  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: const Color(0xffcfd2e6),
      strokeWidth: 1.5,
      dashPattern: const [6, 6],
      borderType: BorderType.RRect,
      radius: const Radius.circular(28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xfffbfbff),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top circular icon
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xfff1f2fb),
              ),
              child: const Icon(
                Icons.picture_as_pdf_rounded,
                size: 32,
                color: Color(0xff6b6f8d),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Ready for review?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xff1a1a1a),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Export a detailed PDF breakdown of\nyour monthly finances for tax or\nbookkeeping.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Color(0xff6b6f8d),
              ),
            ),

            const SizedBox(height: 28),

            // Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff3525CD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: onGenerate,
                child: Text(
                  generatedReport == null
                      ? 'Generate Report'
                      : 'Regenerate Report',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (reportError != null) ...[
              const SizedBox(height: 12),
              Text(
                reportError!,
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
    // CardBox(
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               const Text(
    //                 'Use the same Python ML/report pipeline on live home and wallet data.',
    //                 style: TextStyle(color: Colors.white70, fontSize: 12),
    //               ),
    //               const SizedBox(height: 12),
    //               SizedBox(
    //                 width: double.infinity,
    //                 child: ElevatedButton.icon(
    //                   onPressed: onGenerate,
    //                   icon: const Icon(Icons.assessment),
    //                   label: Text(
    //                     generatedReport == null
    //                         ? 'Generate Report'
    //                         : 'Regenerate Report',
    //                   ),
    //                 ),
    //               ),
    //               if (reportError != null) ...[
    //                 const SizedBox(height: 12),
    //                 Text(
    //                   reportError!,
    //                   style: const TextStyle(
    //                     color: Colors.orangeAccent,
    //                     fontSize: 11,
    //                   ),
    //                 ),
    //               ],
    //             ],
    //           ),
    //         )