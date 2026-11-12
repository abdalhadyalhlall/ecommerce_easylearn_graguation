import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get apiBaseUrl {
    if (!dotenv.isInitialized) {
      throw StateError('Load the .env file before accessing API settings.');
    }
    final configuredUrl = dotenv.env['API_BASE_URL']?.trim();
    if (configuredUrl == null || configuredUrl.isEmpty) {
      throw StateError('API_BASE_URL is missing from the .env file.');
    }
    return configuredUrl.endsWith('/') ? configuredUrl : '$configuredUrl/';
  }

  static String get apiKey {
    if (!dotenv.isInitialized) {
      throw StateError('Load the .env file before accessing API settings.');
    }
    final configuredKey = dotenv.env['API_KEY']?.trim();
    if (configuredKey == null || configuredKey.isEmpty) {
      throw StateError('API_KEY is missing from the .env file.');
    }
    return configuredKey;
  }

  static const String login = 'client/login';
  static const String register = 'client/register';
  static const String verifyOtp = 'client/otp/verify';
  static const String resendOtp = 'client/otp/resend';
  static const String categories = 'client/categories';
  static const String products = 'client/products';
  static const String favorites = 'client/favorites';
  static const String favoriteStore = 'client/favorites/store';
  static const String favoriteDestroy = 'client/favorites/destroy';
  static const String cart = 'client/carts';
  static const String cartStore = 'client/carts/store';
  static const String cartDestroy = 'client/carts/destroy';
  static const String orders = 'client/orders';
  static const String orderStore = 'client/orders/store';
  static const String paymentsProcess = 'client/payments/process';
  static const String profile = 'client/profile';
  static const String profileUpdate = 'client/profile/update';

  static String productDetails(String slug) =>
      '$products/show/${Uri.encodeComponent(slug)}';
  static String orderDetails(String code) =>
      '$orders/show/${Uri.encodeComponent(code)}';
  static String orderPayment(String code) =>
      '$orders/pay/${Uri.encodeComponent(code)}';
}
