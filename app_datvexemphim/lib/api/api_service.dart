import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:app_datvexemphim/data/services/storage_service.dart';

class ApiService {
  static Dio? _dio;

  static Future<void> init() async {
    String baseUrl;

    if (kIsWeb) {
      // Web thì luôn dùng localhost
      baseUrl = "http://localhost:5000/api/v1";
    } else if (Platform.isAndroid || Platform.isIOS) {
      final info = NetworkInfo();
      String? ip =
          await info.getWifiGatewayIP(); // IP máy thật, ví dụ: 192.168.12.103
      baseUrl = "http://${ip ?? '192.168.0.1'}:5000/api/v1";
    } else {
      baseUrl = "http://localhost:5000/api/v1";
    }

    print("❌ APIv4 cần: $baseUrl");
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
  }

  static Dio get dio => _dio!;

  static Future<Response?> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      Response response = await dio.post(endpoint, data: data);
      return response;
    } catch (e) {
      print("❌ API POST Error: $e");
      return null;
    }
  }

  static Future<Response?> delete(String endpoint,
      {Map<String, dynamic>? data}) async {
    try {
      Response response = await dio.delete(endpoint, data: data);
      return response;
    } catch (e) {
      print("❌ API DELETE Error ($endpoint): $e");
      return null;
    }
  }

  static Future<Response?> get(String endpoint,
      {Map<String, dynamic>? params}) async {
    try {
      String? token = await StorageService.getToken();
      Response response = await dio.get(
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
      String? token = await StorageService.getToken();
      Response response = await dio.put(
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
