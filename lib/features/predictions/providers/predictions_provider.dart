/// Predictions Provider for ML services
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tspendly/features/predictions/models/prediction_models.dart';
import 'package:tspendly/features/chatbot/Provider/chat_provider.dart';

const String API_BASE_URL = 'http://localhost:5000';


final predictionsProvider = StateNotifierProvider<PredictionsNotifier, PredictionState>(
  (ref) => PredictionsNotifier(ref),
);


class PredictionState {
  final PredictionResponse? data;
  final bool isLoading;
  final String? error;

  PredictionState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  PredictionState copyWith({
    PredictionResponse? data,
    bool? isLoading,
    String? error,
  }) {
    return PredictionState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}


class PredictionsNotifier extends StateNotifier<PredictionState> {
  final Ref ref;

  PredictionsNotifier(this.ref) : super(PredictionState());

  Future<void> getPredictions({
    required double currentSpending,
    required double budgetLimit,
    required List<Map<String, dynamic>> expenses,
    required int daysInMonth,
    required int currentDay,
    required List<double> historicalMonthly,
    double? currentMonth,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/api/predictions/all-predictions'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'currentSpending': currentSpending,
          'budgetLimit': budgetLimit,
          'expenses': expenses,
          'daysInMonth': daysInMonth,
          'currentDay': currentDay,
          'historicalMonthly': historicalMonthly,
          'currentMonth': currentMonth ?? currentSpending,
        }),
      );

      if (response.statusCode == 200) {
        final raw = jsonDecode(response.body) as Map<String, dynamic>;
        final data = PredictionResponse.fromJson(raw);
        state = state.copyWith(data: data, isLoading: false);

        // Update chatbot financial context so the chat provider can use
        // the latest predictions immediately.
        try {
          ref.read(userFinancialDataProvider.notifier).state = raw;
        } catch (_) {}
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to get predictions: ${response.statusCode}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error: $e',
      );
    }
  }

  Future<OverrunPrediction?> predictOverrun({
    required double currentSpending,
    required double budgetLimit,
    required List<Map<String, dynamic>> expenses,
    int daysInMonth = 30,
    int currentDay = 1,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/api/predictions/predict-overrun'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'currentSpending': currentSpending,
          'budgetLimit': budgetLimit,
          'expenses': expenses,
          'daysInMonth': daysInMonth,
          'currentDay': currentDay,
        }),
      );

      if (response.statusCode == 200) {
        return OverrunPrediction.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error predicting overrun: $e');
      return null;
    }
  }

  Future<MonthlForecast?> forecastMonthly({
    required List<double> historicalMonthly,
    double? currentMonth,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/api/predictions/forecast-monthly'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'historicalMonthly': historicalMonthly,
          'currentMonth': currentMonth,
        }),
      );

      if (response.statusCode == 200) {
        return MonthlForecast.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error forecasting: $e');
      return null;
    }
  }

  Future<CategoryPrediction?> classifyCategory(String description) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/api/predictions/classify-category'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'description': description}),
      );

      if (response.statusCode == 200) {
        return CategoryPrediction.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error classifying: $e');
      return null;
    }
  }
}
