import 'package:dio/dio.dart';
import 'package:app_datvexemphim/data/services/storage_service.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: //"http://localhost:5000/api/v1",
          "http://192.168.12.110:5000/api/v1",
      // "http://192.168.1.11:5000/api/v1",

      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static Future<Response?> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      Response response = await _dio.post(endpoint, data: data);
      return response;
    } catch (e) {
      print("❌ API Error: $e");
      return null;
    }
  }

  static Future<Response?> get(String endpoint,
      {Map<String, dynamic>? params}) async {
    try {
      String? token =
          await StorageService.getToken(); // Lấy token từ StorageService
      Response response = await _dio.get(
        endpoint,
        queryParameters: params,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      return response;
    } catch (e) {
      print("❌ API GET Error ($endpoint): $e");
      return null;
    }
  }

  static Future<Response?> put(
      String endpoint, Map<String, dynamic> data) async {
    try {
      String? token =
          await StorageService.getToken(); // Lấy token từ StorageService
      Response response = await _dio.put(
        endpoint,
        data: data,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      return response;
    } catch (e) {
      print("❌ API PUT Error ($endpoint): $e");
      return null;
    }
  }
}
