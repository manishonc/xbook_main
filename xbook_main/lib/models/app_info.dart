class AppInfo {
  final String appName;
  final String? logo;
  final String appDomain;

  AppInfo({
    required this.appName,
    this.logo,
    required this.appDomain,
  });

  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      appName: json['app_name'] as String,
      logo: json['logo'] as String?,
      appDomain: json['app_domain'] as String,
    );
  }
}
