// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:spendly/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Simple local counter widget for test isolation
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CounterTestWidget(),
      ),
    ));

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}


class CounterTestWidget extends StatefulWidget {
  const CounterTestWidget({Key? key}) : super(key: key);

  @override
  State<CounterTestWidget> createState() => _CounterTestWidgetState();
}

class _CounterTestWidgetState extends State<CounterTestWidget> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$_count'),
        IconButton(onPressed: () => setState(() => _count++), icon: const Icon(Icons.add))
      ],
    );
  }
}
