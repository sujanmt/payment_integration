import 'dart:io';


abstract class Request {
  static const _authentication = 'Authorization';

  static const String userAgent = 'User-Agent';
  static const String contentType = 'Content-Type';
  static const String accept = 'Accept';
  static const String locale = 'locale';

  Future<Map<String, String>> getHeaders();

  Map<String, dynamic>? getBody();

  static Future<Map<String, String>> _createCommonHeader(
      {bool isFormData = false}) async {
    final common = <String, String>{};
    common['Accept'] = 'application/json';
    common['Content-Type'] =
    isFormData ? 'multipart/form-data' : 'application/json';
    common['platform'] = Platform.isIOS ? "ios" : "android";
    return common;
  }

  static Future<Map<String, String>> createAuthHeader(String accessToken,
      {bool isFormData = false}) async {
    Map<String, String> headers = <String, String>{};
    headers.addAll(await _createCommonHeader(isFormData: isFormData));
    headers[_authentication] = 'Bearer $accessToken';
    return headers;
  }

  static Future<Map<String, String>> createHeader() async {
    Map<String, String> headers = <String, String>{};
    headers.addAll(await _createCommonHeader());
    return headers;
  }

  static String urlEncodeForFormData(Map<String, String> map) {
    return map.keys
        .map((key) =>
    '${Uri.encodeComponent(key)}=${Uri.encodeComponent(map[key]!)}')
        .join('&');
  }

  static Map<String, String> toParamMap(String key, List<String> list) {
    final ret = <String, String>{};
    list.asMap().forEach((index, value) {
      ret['$key[$index]'] = value.toString();
    });
    return ret;
  }
}
