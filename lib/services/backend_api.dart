import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BackendApi {
  final Dio _dio;
  BackendApi._(this._dio);

  static BackendApi create() {
    // Use local debug backend on port 5001 by default (safe endpoint available)
    // On web, dotenv may not be initialized, so just use the default
    String baseUrl = 'http://127.0.0.1:5001';
    try {
      baseUrl = dotenv.env['BACKEND_URL'] ?? baseUrl;
    } catch (e) {
      // dotenv not initialized (normal on web), use default
    }
    final dio = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: Duration(milliseconds: 5000)));
    return BackendApi._(dio);
  }

  Future<Map<String, dynamic>> forecastMonthly(List<double> historical) async {
    final resp = await _dio.post('/api/predictions/forecast-monthly', data: {
      'historicalMonthlyExpenses': historical,
    });
    return Map<String, dynamic>.from(resp.data);
  }

  Future<Map<String, dynamic>> predictOverrun(Map<String, dynamic> payload) async {
    // Call the safe endpoint to avoid serialization issues during local debugging
    final resp = await _dio.post('/api/predictions/predict-overrun-safe', data: payload);
    return Map<String, dynamic>.from(resp.data);
  }

  Future<Map<String, dynamic>> generateReport(Map<String, dynamic> payload) async {
    final resp = await _dio.post('/api/predictions/generate-report', data: payload);
    return Map<String, dynamic>.from(resp.data);
  }
}
