import 'package:flutter/material.dart';
import 'package:spendly/features/Report/controllers/report_controller.dart';
import 'package:spendly/features/Report/domain/models/generated_report.dart';
import 'package:printing/printing.dart';

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  final _controller = ReportController();
  late Future<List<GeneratedReport>> _future;

  @override
  void initState() {
    super.initState();
    _future = _controller.loadSavedReports();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _controller.loadSavedReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generated Reports')),
      body: FutureBuilder<List<GeneratedReport>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data ?? [];
          if (items.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('No generated reports yet.'), const SizedBox(height: 12), ElevatedButton(onPressed: _refresh, child: const Text('Refresh'))]));

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, idx) {
                final r = items[idx];
                return ListTile(
                  title: Text(r.filename),
                  subtitle: Text('${r.frequency.toUpperCase()} • ${r.createdAt.toLocal()}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () async {
                      try {
                        final bytes = await _controller.loadSavedReportBytes(r);
                        if (bytes != null) {
                          await Printing.sharePdf(bytes: bytes, filename: r.filename);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved report data not found')));
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open report: $e')));
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
