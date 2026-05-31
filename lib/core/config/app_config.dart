import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static String get adminAuthBaseUrl {
    final value = dotenv.env['ADMIN_AUTH_BASE_URL']?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('ADMIN_AUTH_BASE_URL is missing from .env');
    }
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  static String get authBaseUrl {
    final value = dotenv.env['AUTH_BASE_URL']?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('AUTH_BASE_URL is missing from .env');
    }
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  static String get contentDeviceBaseUrl {
    final value = dotenv.env['CONTENT_DEVICE_BASE_URL']?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('CONTENT_DEVICE_BASE_URL is missing from .env');
    }
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  static String get errorBaseUrl {
    final value = dotenv.env['ERROR_BASE_URL']?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('ERROR_BASE_URL is missing from .env');
    }
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  static String get activityBaseUrl {
    final value = dotenv.env['ACTIVITY_BASE_URL']?.trim();
    if (value != null && value.isNotEmpty) {
      return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
    }
    return errorBaseUrl.replaceFirst(RegExp(r'/errors$'), '');
  }

  static String get realtimeBaseUrl {
    final value = dotenv.env['REALTIME_BASE_URL']?.trim();
    if (value != null && value.isNotEmpty) {
      return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
    }
    final uri = Uri.parse(errorBaseUrl);
    return uri.replace(port: 4003, path: '').toString().replaceFirst(RegExp(r'/$'), '');
  }
}
