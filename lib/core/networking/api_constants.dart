const _configuredApiUrl = String.fromEnvironment('API_BASE_URL');
const _configuredApiKey = String.fromEnvironment('API_KEY');

class ApiConstants {
  static String get apiBaseUrl {
    if (_configuredApiUrl.isNotEmpty) {
      return _configuredApiUrl.endsWith('/')
          ? _configuredApiUrl
          : '$_configuredApiUrl/';
    }
    return 'https://easylearn.devawy.com/api/';
  }

  static String get apiKey => _configuredApiKey;

  static const String login = 'client/login';
  static const String register = 'client/register';
  static const String verifyOtp = 'client/otp/verify';
  static const String resendOtp = 'client/otp/resend';
  static const String categories = 'v1/categories';
  static const String products = 'v1/products';
  static const String cart = 'cart/v1';
  static const String orders = 'orders/v1';
}
