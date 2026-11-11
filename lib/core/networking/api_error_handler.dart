import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiErrorHandler {
  static const String _defaultMessage =
      'Something went wrong, please try again';

  static String getMessage(Object error) {
    if (error is! DioException) {
      debugPrint('Unexpected error: $error');
      if (error is StateError) return error.message;
      return _defaultMessage;
    }

    if (error.error is StateError) {
      return (error.error as StateError).message;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out, please try again';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      case DioExceptionType.badResponse:
        return _getServerMessage(error.response?.data);
      default:
        return _defaultMessage;
    }
  }

  static String _getServerMessage(dynamic data) {
    if (data is! Map) return _defaultMessage;

    final message = data['message'];
    if (message is String) return message;
    final errors = message is Map ? message : data['errors'];
    if (errors is Map) {
      final messages = errors.values
          .expand((fieldErrors) => fieldErrors is List ? fieldErrors : [fieldErrors])
          .whereType<String>()
          .toList();
      if (messages.isNotEmpty) return messages.join('\n');
    }
    return _defaultMessage;
  }
}
