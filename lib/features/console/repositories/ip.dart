import 'package:get_ip_address/get_ip_address.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ip.g.dart';

@riverpod
Future<String?> localIp(Ref ref) {
  final networkInfo = NetworkInfo();

  return networkInfo.getWifiIP();
}

@riverpod
Future<String?> publicIp(Ref ref) async {
  final ipAddress = IpAddress();
  var ip = await ipAddress.getIpAddress();
  return ip as String?;
}
