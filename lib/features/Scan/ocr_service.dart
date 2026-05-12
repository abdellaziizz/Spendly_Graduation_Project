import 'dart:io';
import 'package:dio/dio.dart';
import 'package:tspendly/features/Scan/core/dio_client.dart';

/// Sends a receipt image to OCR.Space and returns the extracted plain text.
/// Uses the existing [DioClient] which already has the API key baked in.
class OcrService {
  final Dio _dio = DioClient.createDio();

  /// Sends [imageFile] to OCR.Space via multipart/form-data.
  /// Returns the concatenated parsed text from all pages.
  /// Throws a [OcrException] on failure.
  Future<String> extractText(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last.split('\\').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'language': 'ara,eng', // Support Arabic and English simultaneously
        'isOverlayRequired': false,
        'detectOrientation': true,
        'scale': true,
        'isTable': false,
        'OCREngine': 2, // Engine 2 is better for mixed-language receipts
      });

      final response = await _dio.post(
        '', // Base URL already set in DioClient
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final data = response.data;

      // Check for OCR.Space-level errors
      if (data is! Map || data['IsErroredOnProcessing'] == true) {
        final errMsg = data?['ErrorMessage']?.toString() ?? 'Unknown OCR error';
        throw OcrException(errMsg);
      }

      final parsedResults = data['ParsedResults'] as List?;
      if (parsedResults == null || parsedResults.isEmpty) {
        throw const OcrException('No text detected in the image.');
      }

      // Concatenate text from all parsed pages
      final buffer = StringBuffer();
      for (final result in parsedResults) {
        final exitCode = result['FileParseExitCode'];
        if (exitCode == 1) {
          // Exit code 1 = success
          buffer.writeln(result['ParsedText'] ?? '');
        }
      }

      final extractedText = buffer.toString().trim();
      if (extractedText.isEmpty) {
        throw const OcrException('Could not read any text from the receipt.');
      }

      return extractedText;
    } on DioException catch (e) {
      throw OcrException('Network error: ${e.message}');
    }
  }
}

/// Typed exception for OCR failures — lets the UI show actionable messages.
class OcrException implements Exception {
  final String message;
  const OcrException(this.message);

  @override
  String toString() => 'OcrException: $message';
}
