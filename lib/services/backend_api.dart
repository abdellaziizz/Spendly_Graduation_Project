import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BackendApi {
  final Dio _dio;
  BackendApi._(this._dio);

  static BackendApi create() {
    final baseUrl = dotenv.env['BACKEND_URL'] ?? 'http://127.0.0.1:5000';
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
    final resp = await _dio.post('/api/predictions/predict-overrun', data: payload);
    return Map<String, dynamic>.from(resp.data);
  }

  Future<Map<String, dynamic>> generateReport(Map<String, dynamic> payload) async {
    final resp = await _dio.post('/api/predictions/generate-report', data: payload);
    return Map<String, dynamic>.from(resp.data);
  }
}
