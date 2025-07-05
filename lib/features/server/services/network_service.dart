import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetworkInfoData {
  final String? localIp;
  final String? publicIp;

  NetworkInfoData({this.localIp, this.publicIp});
}

class NetworkInfoNotifier extends AsyncNotifier<NetworkInfoData> {
  @override
  Future<NetworkInfoData> build() async {
    return await getNetworkInfo();
  }

  Future<NetworkInfoData> getNetworkInfo() async {
    String? localIp;
    String? publicIp;

    try {
      final info = NetworkInfo();
      localIp = await info.getWifiIP();
    } catch (e) {
      print('Error getting WiFi IP: $e');
    }

    if (localIp == null || localIp.isEmpty) {
      localIp = await _getLocalIpFromInterfaces();
    }

    try {
      final response = await http
          .get(Uri.parse('https://ipv4.icanhazip.com'))
          .timeout(Duration(seconds: 5));
      if (response.statusCode == 200) {
        publicIp = response.body.trim();
      }
    } catch (e) {
      print('Error getting public IP: $e');
      try {
        final response = await http
            .get(Uri.parse('https://api.ipify.org'))
            .timeout(Duration(seconds: 5));
        if (response.statusCode == 200) {
          publicIp = response.body.trim();
        }
      } catch (e2) {
        print('Error getting public IP from alternative service: $e2');
      }
    }

    return NetworkInfoData(localIp: localIp, publicIp: publicIp);
  }

  Future<String?> _getLocalIpFromInterfaces() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (final interface in interfaces) {
        if (interface.name.toLowerCase().contains('wlan') ||
            interface.name.toLowerCase().contains('eth') ||
            interface.name.toLowerCase().contains('en')) {
          for (final address in interface.addresses) {
            if (address.type == InternetAddressType.IPv4 &&
                !address.isLoopback) {
              return address.address;
            }
          }
        }
      }
    } catch (e) {
      print('Error getting local IP from interfaces: $e');
    }
    return null;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => getNetworkInfo());
  }
}

final networkInfoProvider =
    AsyncNotifierProvider<NetworkInfoNotifier, NetworkInfoData>(() {
      return NetworkInfoNotifier();
    });
