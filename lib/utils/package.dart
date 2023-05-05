// 获取应用程序的版本号
import 'package:package_info_plus/package_info_plus.dart';

Future<String> getAppVersion() async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final String version = packageInfo.version;
  return version;
}
