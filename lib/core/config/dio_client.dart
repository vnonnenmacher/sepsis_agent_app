import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

final String baseUrl = kIsWeb 
    ? 'http://localhost:8000'  // Para Web
    : 'http://10.0.2.2:8000';  // Para Mobile (emulador)

class DioClient {
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );

    dio.interceptors.add(LogInterceptor(responseBody: true));

    return dio;
  }
}
