import 'dart:io';
import 'package:dio/dio.dart';

class CloudinaryService {
  static const String _cloudName = 'app-datvexemphim';
  static const String _uploadPreset = 'app_datvexemphim';
  static const String _apiUrl = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  final Dio _dio = Dio();

  Future<String?> uploadImage(File imageFile) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
        'upload_preset': _uploadPreset,
      });

      final response = await _dio.post(_apiUrl, data: formData);
      
      if (response.statusCode == 200) {
        return response.data['secure_url'];
      }
      return null;
    } catch (e) {
      print('❌ Cloudinary upload error: $e');
      return null;
    }
  }
}