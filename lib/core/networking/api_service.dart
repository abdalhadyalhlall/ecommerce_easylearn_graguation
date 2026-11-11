import 'package:clean_arch_session/core/cache/cache_const.dart';
import 'package:clean_arch_session/core/cache/cache_helper.dart';
import 'package:clean_arch_session/core/networking/api_constants.dart';
import 'package:dio/dio.dart';

class ApiService {
  final Dio dio;

  ApiService(this.dio) {
    dio.options.baseUrl = ApiConstants.apiBaseUrl;
    dio.options.connectTimeout = const Duration(seconds: 20);
    dio.options.receiveTimeout = const Duration(seconds: 20);
    dio.options.headers = {
      'Accept': 'application/json',
      'x-api-key': ApiConstants.apiKey,
    };
    dio.interceptors.add(InterceptorsWrapper(onRequest: _addHeaders));
  }

  Future<void> _addHeaders(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      if (ApiConstants.apiKey.isEmpty) {
        throw StateError(
          'API key is missing. Provide it with --dart-define=API_KEY=...',
        );
      }

      options.headers['x-api-key'] = ApiConstants.apiKey;
      if (_requiresAuthentication(options.path)) {
        final token = await CacheHelper.getSecureData(
          key: CacheConstants.userToken,
        );
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
      handler.next(options);
    } catch (error) {
      handler.reject(
        error is DioException
            ? error
            : DioException(requestOptions: options, error: error),
      );
    }
  }

  bool _requiresAuthentication(String path) {
    return !path.endsWith(ApiConstants.login) &&
        !path.endsWith(ApiConstants.register) &&
        !path.endsWith(ApiConstants.verifyOtp) &&
        !path.endsWith(ApiConstants.resendOtp);
  }

  Future<Response<dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.get<dynamic>(endpoint, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> post(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.post<dynamic>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response<dynamic>> put(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.put<dynamic>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response<dynamic>> delete(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.delete<dynamic>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
    );
  }
}
