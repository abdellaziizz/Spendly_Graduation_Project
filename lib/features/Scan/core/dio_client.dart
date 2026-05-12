import 'package:dio/dio.dart';

class DioClient {
  static Dio createDio() {
    return Dio(
      BaseOptions(
        baseUrl: "https://api.ocr.space/parse/image",
        headers: {"apikey": "K82312112288957"},
      ),
    );
  }
}
