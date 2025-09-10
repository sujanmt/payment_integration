import 'dart:async';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../shared/service/internet_connection.dart';
import '../shared/singletons/baseurl_singleton.dart';

class RequestClient {
  static RequestClient? _instance;
  late Dio _dio;

  factory RequestClient() {
    _instance = RequestClient._internal();
    return _instance!;
  }

  RequestClient._internal() {
    final options = BaseOptions(
      validateStatus: (status) {
        return status! < 501;
      },
      baseUrl: BaseURL.getInstance.getBaseUrl(),
      connectTimeout: const Duration(seconds: _timeoutInSeconds), // 5 seconds
      receiveTimeout: const Duration(seconds: _timeoutInSeconds), // 3 seconds
    );
    _dio = Dio(options)
      ..interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: false,
          responseBody: false,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
  }

  static const int _timeoutInSeconds = 60;

  Future<dynamic> get(
    String url,
    Map<String, String> headers, {
    Map<String, dynamic>? queryParameters,
  }) async {
    var isInternet = await CheckInternetConnection().isInternet();
    if (isInternet) {
      _dio.options.headers = headers;
      final response = await _dio.get(url, queryParameters: queryParameters);
      return response;
    } else {
      return 800;
    }
  }

  Future<dynamic> post(
    String url,
    Map<String, String> headers, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    var isInternet = await CheckInternetConnection().isInternet();
    if (isInternet) {
      _dio.options.headers = headers;
      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } else {
      return 800;
    }
  }

  Future<dynamic> patch(
    String url,
    Map<String, String> headers, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    var isInternet = await CheckInternetConnection().isInternet();
    if (isInternet) {
      _dio.options.headers = headers;
      final response = await _dio.patch(
        url,
        data: data,
        queryParameters: queryParameters,
      );

      return response;
    } else {
      return 800;
    }
  }

  Future<dynamic> put(
    String url,
    Map<String, String> headers, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    var isInternet = await CheckInternetConnection().isInternet();
    if (isInternet) {
      _dio.options.headers = headers;
      final response = await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
      );

      return response;
    } else {
      return 800;
    }
  }

  Future<dynamic> delete(
    String url,
    Map<String, String> headers, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    var isInternet = await CheckInternetConnection().isInternet();
    if (isInternet) {
      _dio.options.headers = headers;
      final response = await _dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } else {
      return 800;
    }
  }
}
