import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl:

          "http://localhost:5000/api/v1", // Nếu chạy trên Android Emulator
          //"http://10.21.8.240:5000/api/v1",
          // "http://192.168.1.11:5000/api/v1",

          // "http://localhost:5000/api/v1", // Nếu chạy trên Android Emulator
          // "http://10.21.0.61:5000/api/v1",
          "http://192.168.1.10:5000/api/v1",

      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static Future<Response?> post(String endpoint, Map<String, dynamic> data) async {
    try {
      Response response = await _dio.post(endpoint, data: data);
      return response;
    } catch (e) {
      print("❌ API Error: $e");
      return null;
    }
  }

  static Future<Response?> get(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      Response response = await _dio.get(endpoint, queryParameters: params);
      return response;
    } catch (e) {
      print("❌ API GET Error: $e");
      return null;
    }
  }
}
