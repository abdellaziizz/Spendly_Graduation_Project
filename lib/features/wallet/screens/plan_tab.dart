import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wallet_provider.dart';

class PlanTab extends ConsumerStatefulWidget {
  const PlanTab({Key? key}) : super(key: key);

  @override
  ConsumerState<PlanTab> createState() => _PlanTabState();
}

class _PlanTabState extends ConsumerState<PlanTab> {
  @override
  Widget build(BuildContext context) {
    final budgets = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ...budgets.map((budget) {
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.title == 'Education' ? 'Edit Current Budget' : 'Set Limit',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                      ),
                      const SizedBox(height: 8.0),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter the title',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // Confirm logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D3B66), // Dark blue per design
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
              ),
              child: const Text('Confirm', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }
}
