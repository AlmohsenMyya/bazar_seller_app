import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';

import '../../data/model/response/base/api_response.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:package_info_plus/package_info_plus.dart';

Future<String> getAppVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}
class ApiClient {
  // ...
  final http.Client _client = http.Client();
  Future<ApiResponse> get(String path, Map<String, String> headers) async {
    try {
      final response = await _client.get(Uri.parse(path), headers: headers);
      return ApiResponse(response.statusCode, response.body);
    } catch (e) {
      return ApiResponse(0, e.toString());
    }
  }

// ...
}


class ApiResponse {
  final int statusCode;
  final String? data;

  ApiResponse(this.statusCode, this.data);
}

class VersionRepository {
  final ApiClient _apiClient;

  VersionRepository(this._apiClient);

  Future<String?> getVersion() async {
    final response = await _apiClient.get('https://tiktakbazaar.com/api/v1/version', {});
    if (response.statusCode == 200 && response.data != null) {
      final data = json.decode(response.data!);
      final version = data['data']['name'] as String?;
      return version;
    } else {
      return null;
    }
  }
}

class VersionProvider extends ChangeNotifier {
  final VersionRepository _versionRepository;

  VersionProvider(this._versionRepository);

  String? _currentVersion;
  String? _apiVersion;
  String? get currentVersion => _currentVersion;
  String? get apiVersion => _apiVersion;

  Future<void> checkVersion() async {
    _apiVersion = await _versionRepository.getVersion();
    final appVersion = await getAppVersion();
    if (_apiVersion != null && _apiVersion == appVersion) {
      // Do something if the app version matches the API version
    } else {
      // Do something else if the app version does not match the API version
    }
    _currentVersion = appVersion;
    notifyListeners();
  }
}

