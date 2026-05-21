import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:spendly/features/Report/controllers/report_controller.dart';
import 'package:spendly/features/Report/domain/models/live_insights_data.dart';

class ReportPdfPreview extends StatelessWidget {
  const ReportPdfPreview({
    super.key,
    required this.data,
    required this.freq,
  });

  final LiveInsightsData data;
  final ReportFrequency freq;

  @override
  Widget build(BuildContext context) {
    final controller = ReportController();
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview ${freq.name.toUpperCase()} Report'),
      ),
      body: PdfPreview(
        build: (format) async => controller.buildPdf(data, freq),
        allowSharing: true,
        useActions: true,
      ),
    );
  }
}
