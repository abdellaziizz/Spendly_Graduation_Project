import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:spendly/features/Report/domain/models/live_insights_data.dart';

enum ReportFrequency { daily, weekly, monthly }

class ReportController {
  // Build a PDF document from the live insights data and selected frequency
  Future<Uint8List> buildPdf(LiveInsightsData data, ReportFrequency freq) async {
    final doc = pw.Document();

    final primary = PdfColor.fromInt(0xFF3525CD);
    final textColor = PdfColor.fromInt(0xFF1A1A1A);

    final title = 'Spendly ${_freqToLabel(freq)} Report';
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm');

    // Load app logo from assets if available
    pw.MemoryImage? logoImage;
    try {
      final logoData = await rootBundle.load('assets/logo/logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (_) {
      logoImage = null;
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            color: PdfColors.white,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(children: [
                      if (logoImage != null) pw.Image(logoImage, width: 40, height: 40),
                      pw.SizedBox(width: 8),
                      pw.Text(title,
                          style: pw.TextStyle(
                              fontSize: 20,
                              color: primary,
                              fontWeight: pw.FontWeight.bold)),
                    ]),
                    pw.Text(formatter.format(now),
                        style: pw.TextStyle(fontSize: 10, color: textColor)),
                  ],
                ),
                pw.SizedBox(height: 12),

                      // Summary
                      pw.Text('Summary',
                        style:
                          pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      pw.Text(data.summary, style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 12),

                // Budget status
                pw.Text('Budget Status',
                  style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Current spending: \$${data.currentSpending.toStringAsFixed(2)} / Budget: \$${data.budgetLimit.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 12),

                // Category breakdown table
                pw.Text('Category Breakdown',
                    style:
                        pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                if (data.categoryBreakdown.isNotEmpty)
                  pw.Table.fromTextArray(
                    context: context,
                    headers: ['Category', 'Spent', 'Budget'],
                    data: data.categoryBreakdown
                        .map((c) => [
                              c.name,
                              c.amount.toStringAsFixed(2),
                              c.budgetLimit.toStringAsFixed(2)
                            ])
                        .toList(),
                  )
                else
                  pw.Text('No category data available'),

                pw.SizedBox(height: 12),
                // Simple category bar chart
                if (data.categoryBreakdown.isNotEmpty) ...[
                  pw.Text('Category Chart',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  _buildCategoryChart(data),
                ],

                pw.SizedBox(height: 12),

                // Forecast / predictions
                pw.Text('Forecasts & Predictions',
                    style:
                        pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Predicted monthly spending: \$${data.monthlyForecast.toStringAsFixed(2)} (trend: ${data.trend})',
                  style: pw.TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _buildCategoryChart(LiveInsightsData data) {
    final items = data.categoryBreakdown;
    final maxAmount = items.map((e) => e.amount).fold<double>(0.0, (a, b) => a > b ? a : b);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: items.map((c) {
        final widthFactor = maxAmount <= 0 ? 0.0 : (c.amount / maxAmount);
        return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('${c.name} — \$${c.amount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 10)),
              pw.Container(
                height: 10,
                width: 200,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Row(children: [
                  pw.Container(
                    width: 200 * widthFactor,
                    height: 10,
                    color: PdfColor.fromInt((c.color.value & 0xFFFFFF) | 0xFF000000),
                  )
                ]),
              ),
              pw.SizedBox(height: 6),
            ]);
      }).toList(),
    );
  }

  Future<void> sharePdf(Uint8List bytes, String filename) async {
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  String _freqToLabel(ReportFrequency freq) {
    switch (freq) {
      case ReportFrequency.daily:
        return 'Daily';
      case ReportFrequency.weekly:
        return 'Weekly';
      case ReportFrequency.monthly:
      default:
        return 'Monthly';
    }
  }
}
