import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/admin_auth_service.dart';
import '../../core/config/app_config.dart';

final adminAuthServiceProvider = Provider<AdminAuthService>((ref) {
  return AdminAuthService(
    baseUrl: AppConfig.adminAuthBaseUrl,
    authBaseUrl: AppConfig.authBaseUrl,
    contentDeviceBaseUrl: AppConfig.contentDeviceBaseUrl,
    errorBaseUrl: AppConfig.errorBaseUrl,
    activityBaseUrl: AppConfig.activityBaseUrl,
  );
});
