// ─── User / Customer Model ───────────────────────────────────────────────────

class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String country;
  final String plan;
  final String status; // active, banned, flagged, suspended
  final bool isOnline;
  final int deviceCount;
  final double totalUsageGB;
  final double monthlyUsageGB;
  final DateTime joinDate;
  final DateTime nextPaymentDate;
  final double monthlyCharge;
  final int errorCount;
  final List<PaymentRecord> paymentHistory;
  final List<DeviceInfo> devices;
  final List<CustomerOffer> offers;
  final String? avatarInitials;
  final String businessName;
  final String? businessId;

  const Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
    required this.plan,
    required this.status,
    required this.isOnline,
    required this.deviceCount,
    required this.totalUsageGB,
    required this.monthlyUsageGB,
    required this.joinDate,
    required this.nextPaymentDate,
    required this.monthlyCharge,
    required this.errorCount,
    required this.paymentHistory,
    required this.devices,
    this.offers = const [],
    this.avatarInitials,
    required this.businessName,
    this.businessId,
  });
}

class CustomerOffer {
  final String id;
  final String type;
  final String? planId;
  final String? planName;
  final double? originalAmount;
  final double? offerAmount;
  final String currency;
  final int? extensionDays;
  final DateTime? previousEndsAt;
  final DateTime? newEndsAt;
  final DateTime? validUntil;
  final DateTime? createdAt;

  const CustomerOffer({
    required this.id,
    required this.type,
    this.planId,
    this.planName,
    this.originalAmount,
    this.offerAmount,
    this.currency = 'INR',
    this.extensionDays,
    this.previousEndsAt,
    this.newEndsAt,
    this.validUntil,
    this.createdAt,
  });

  bool get isPlanOffer => type == 'PLAN_OFFER';
  bool get isPlanExtension => type == 'PLAN_EXTENSION';
}

class MobileNotification {
  final int id;
  final String target;
  final String? businessName;
  final String title;
  final String message;
  final String category;
  final DateTime sentAt;

  const MobileNotification({
    required this.id,
    required this.target,
    this.businessName,
    required this.title,
    required this.message,
    required this.category,
    required this.sentAt,
  });
}

// ─── Device Model ─────────────────────────────────────────────────────────────

class DeviceInfo {
  final String deviceId;
  final String deviceName;
  final String macAddress;
  final String androidVersion;
  final String osName;
  final String model;
  final String manufacturer;
  final bool isOnline;
  final bool isActive;
  final String ownerId;
  final String ownerName;
  final String businessName;
  final DateTime registeredAt;
  final DateTime? lastSeen;
  final String appVersion;
  final String ipAddress;
  final String location;
  final double storageUsedGB;
  final double storageTotalGB;
  final int batteryLevel;
  final String firmwareVersion;
  final String serialNumber;
  final Map<String, String> extraDetails;

  const DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.macAddress,
    required this.androidVersion,
    required this.osName,
    required this.model,
    required this.manufacturer,
    required this.isOnline,
    required this.isActive,
    required this.ownerId,
    required this.ownerName,
    required this.businessName,
    required this.registeredAt,
    this.lastSeen,
    required this.appVersion,
    required this.ipAddress,
    required this.location,
    required this.storageUsedGB,
    required this.storageTotalGB,
    required this.batteryLevel,
    required this.firmwareVersion,
    required this.serialNumber,
    this.extraDetails = const {},
  });
}

// ─── Payment Model ────────────────────────────────────────────────────────────

class PaymentRecord {
  final String transactionId;
  final DateTime date;
  final double amount;
  final String currency;
  final String status; // success, pending, failed, refunded
  final String method; // card, upi, bank, wallet
  final String customerId;
  final String customerName;
  final String businessName;
  final String plan;
  final String description;
  final String? cardLast4;
  final String? bankName;
  final String invoiceId;
  final Map<String, String> extraDetails;

  const PaymentRecord({
    required this.transactionId,
    required this.date,
    required this.amount,
    required this.currency,
    required this.status,
    required this.method,
    required this.customerId,
    required this.customerName,
    required this.businessName,
    required this.plan,
    required this.description,
    this.cardLast4,
    this.bankName,
    required this.invoiceId,
    this.extraDetails = const {},
  });
}

// ─── Error Model ──────────────────────────────────────────────────────────────

class RevenueOverview {
  final double totalRevenue;
  final double revenueThisMonth;
  final List<PaymentRecord> transactions;

  const RevenueOverview({
    required this.totalRevenue,
    required this.revenueThisMonth,
    required this.transactions,
  });
}

class ErrorRecord {
  final String errorId;
  final DateTime timestamp;
  final String errorCode;
  final String errorType; // crash, network, auth, payment, hardware
  final String severity; // critical, high, medium, low
  final String message;
  final String stackTrace;
  final String deviceId;
  final String deviceName;
  final String ownerId;
  final String ownerName;
  final String businessName;
  final String appVersion;
  final String osVersion;
  final String status; // open, investigating, resolved, ignored
  final String? resolvedAt;
  final String? resolvedBy;
  final Map<String, String> extraDetails;

  const ErrorRecord({
    required this.errorId,
    required this.timestamp,
    required this.errorCode,
    required this.errorType,
    required this.severity,
    required this.message,
    required this.stackTrace,
    required this.deviceId,
    required this.deviceName,
    required this.ownerId,
    required this.ownerName,
    required this.businessName,
    required this.appVersion,
    required this.osVersion,
    required this.status,
    this.resolvedAt,
    this.resolvedBy,
    this.extraDetails = const {},
  });
}

// ─── Dashboard Stats Model ────────────────────────────────────────────────────

class DashboardStats {
  final int totalUsers;
  final int activeUsers;
  final int newUsersThisMonth;
  final double userGrowthPercent;
  final int liveDevices;
  final int totalDevices;
  final int offlineDevices;
  final double deviceGrowthPercent;
  final double totalRevenue;
  final double revenueThisMonth;
  final double revenueGrowthPercent;
  final int totalErrors;
  final int openErrors;
  final int criticalErrors;
  final double errorChangePercent;

  const DashboardStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsersThisMonth,
    required this.userGrowthPercent,
    required this.liveDevices,
    required this.totalDevices,
    required this.offlineDevices,
    required this.deviceGrowthPercent,
    required this.totalRevenue,
    required this.revenueThisMonth,
    required this.revenueGrowthPercent,
    required this.totalErrors,
    required this.openErrors,
    required this.criticalErrors,
    required this.errorChangePercent,
  });
}

class ManagedPlan {
  final String id;
  final String name;
  final String summary;
  final int minTvDevices;
  final int maxTvDevices;
  final double amount;
  final String currency;
  final int? trialDays;
  final List<String> features;
  final String? discountName;
  final double? discountAmount;
  final DateTime? discountEndsAt;

  const ManagedPlan({
    required this.id,
    required this.name,
    required this.summary,
    required this.minTvDevices,
    required this.maxTvDevices,
    required this.amount,
    this.currency = 'INR',
    this.trialDays,
    this.features = const [],
    this.discountName,
    this.discountAmount,
    this.discountEndsAt,
  });

  String get tvRangeLabel {
    if (minTvDevices == maxTvDevices) return '$maxTvDevices TV';
    return '$minTvDevices-$maxTvDevices TVs';
  }

  bool get hasActiveDiscount =>
      discountName != null &&
      discountAmount != null &&
      discountAmount! < amount &&
      (discountEndsAt == null || discountEndsAt!.isAfter(DateTime.now()));
}

class ApiRequestCount {
  final String endpoint;
  final int count;

  const ApiRequestCount({
    required this.endpoint,
    required this.count,
  });
}

class DangerousRequestUser {
  final String id;
  final String label;
  final String role;
  final int today;
  final int month;
  final int year;
  final int total;
  final DateTime? lastSeenAt;

  const DangerousRequestUser({
    required this.id,
    required this.label,
    required this.role,
    required this.today,
    required this.month,
    required this.year,
    required this.total,
    this.lastSeenAt,
  });
}

class UserRequestAnalytics {
  final String id;
  final String label;
  final String role;
  final int today;
  final int month;
  final int year;
  final int total;
  final DateTime? lastSeenAt;
  final RequestAnalyticsPeriod currentDay;
  final RequestAnalyticsPeriod currentMonth;
  final RequestAnalyticsPeriod currentYear;

  const UserRequestAnalytics({
    required this.id,
    required this.label,
    required this.role,
    required this.today,
    required this.month,
    required this.year,
    required this.total,
    this.lastSeenAt,
    this.currentDay = const RequestAnalyticsPeriod(
      bucket: '',
      endpoints: [],
    ),
    this.currentMonth = const RequestAnalyticsPeriod(
      bucket: '',
      endpoints: [],
    ),
    this.currentYear = const RequestAnalyticsPeriod(
      bucket: '',
      endpoints: [],
    ),
  });
}

class RequestAnalyticsPeriod {
  final String bucket;
  final List<ApiRequestCount> endpoints;

  const RequestAnalyticsPeriod({
    required this.bucket,
    required this.endpoints,
  });
}

class RequestAnalytics {
  final DateTime? generatedAt;
  final int totalRequests;
  final RequestAnalyticsPeriod currentDay;
  final RequestAnalyticsPeriod currentMonth;
  final RequestAnalyticsPeriod currentYear;
  final List<DangerousRequestUser> dangerousUsers;
  final List<UserRequestAnalytics> users;

  const RequestAnalytics({
    this.generatedAt,
    this.totalRequests = 0,
    this.currentDay = const RequestAnalyticsPeriod(
      bucket: '',
      endpoints: [],
    ),
    this.currentMonth = const RequestAnalyticsPeriod(
      bucket: '',
      endpoints: [],
    ),
    this.currentYear = const RequestAnalyticsPeriod(
      bucket: '',
      endpoints: [],
    ),
    this.dangerousUsers = const [],
    this.users = const [],
  });

  int get todayTotal =>
      currentDay.endpoints.fold(0, (sum, item) => sum + item.count);
}

class DashboardChartData {
  final List<String> labels;
  final List<double> revenue;
  final List<double> users;
  final List<double> devices;

  const DashboardChartData({
    required this.labels,
    required this.revenue,
    required this.users,
    required this.devices,
  });
}

class DashboardActivity {
  final String title;
  final String subtitle;
  final String type;
  final DateTime timestamp;

  const DashboardActivity({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.timestamp,
  });
}

// ─── Admin User ───────────────────────────────────────────────────────────────

class AdminUser {
  final String id;
  final String name;
  final String firstName;
  final String lastName;
  final String mobile;
  final int? age;
  final String address;
  final String email;
  final String role;
  final bool isActive;
  final String? createdById;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final String? avatarUrl;

  const AdminUser({
    required this.id,
    required this.name,
    this.firstName = '',
    this.lastName = '',
    this.mobile = '',
    this.age,
    this.address = '',
    required this.email,
    required this.role,
    this.isActive = true,
    this.createdById,
    this.lastLoginAt,
    this.createdAt,
    this.avatarUrl,
  });

  String get status => isActive ? 'Active' : 'Blocked';
  bool get isSuperAdmin => role.toUpperCase() == 'SUPERADMIN';
}
