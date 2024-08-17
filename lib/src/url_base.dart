import 'package:esp_rainmaker/esp_rainmaker.dart';

/// Gets base string URLs for the API based on the API version.
///
/// Is a fully static class that stores the base URL and
/// provides methods to add data on to the base.
class URLBase {
  static const String authHeader = 'Authorization';

  static String _base = 'api.rainmaker.espressif.com';
  static String _basePath = '';

  final APIVersion? _version;

  /// Object for making URIs with the given [version].
  URLBase(this._version);

  Uri getPath(String path, [Map<String, String>? queryParameters]) {
    return Uri.https(
      _base, '$_basePath/${_version!.toShortString()}/$path', queryParameters);
  }

  static set base(String base) {
    List<String> baseWithBasePath = base.split('/');

    if(baseWithBasePath.isEmpty) {
      return;
    }

    _base = baseWithBasePath[0];
    _basePath = baseWithBasePath.sublist(1).join("/");

    if(_basePath.isNotEmpty) {
      _basePath = "/$_basePath";
    }
  }
}

extension ParseToString on APIVersion {
  String toShortString() {
    return toString().split('.').last;
  }
}
