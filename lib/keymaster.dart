import 'package:flutter/services.dart';

class Keymaster {
  static const MethodChannel _channel = MethodChannel('keymaster');

  static Future<bool?> delete(String key, {bool? authRequired}) async {
    bool? result = await _channel.invokeMethod(
      'delete',
      {
        'key': key,
        'auth': authRequired ?? false,
      },
    );

    return result;
  }

  static Future<String?> fetch(String key, {bool? authRequired}) async {
    String? result = await _channel.invokeMethod(
      'fetch',
      {
        'key': key,
        'auth': authRequired ?? false,
      },
    );

    return result;
  }

  static Future<bool?> set(
    String key,
    String value, {
    bool? authRequired,
  }) async {
    bool? result = await _channel.invokeMethod(
      'set',
      {
        'key': key,
        'value': value,
        'auth': authRequired ?? false,
      },
    );

    return result;
  }

  static Future<bool?> update(
    String key,
    String value, {
    bool? authRequired,
  }) async {
    bool? result = await _channel.invokeMethod(
      'update',
      {
        'key': key,
        'value': value,
        'auth': authRequired ?? false,
      },
    );

    return result;
  }
}
