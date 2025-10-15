import 'package:package_info_plus/package_info_plus.dart';

Future<String> getAppVersion() async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version}+${info.buildNumber}';
}
