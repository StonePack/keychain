import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Keymaster {
  static const MethodChannel _channel = MethodChannel('keymaster');

  static Future<bool?> delete(String key, {bool? authRequired}) async {
    String? result = await _channel.invokeMethod(
      'delete',
      {
        'key': key,
        'auth': authRequired,
      },
    );

    if (kDebugMode) print('Keychain Delete Result: $result');
    return result == 'true';
  }

  static Future<String?> fetch(String key, {bool? authRequired}) async {
    String? result = await _channel.invokeMethod(
      'fetch',
      {
        'key': key,
        'auth': authRequired,
      },
    );

    if (kDebugMode) print('Keychain Fetch Result: $result');

    bool isFailure = result?.startsWith('secCopyErr:') ?? true;
    return isFailure ? null : result;
  }

  static Future<bool?> set(
    String key,
    String value, {
    bool? authRequired,
  }) async {
    String? result = await _channel.invokeMethod(
      'set',
      {
        'key': key,
        'value': value,
        'auth': authRequired,
      },
    );

    if (kDebugMode) print('Keychain Set Result: $result');
    return result == 'true';
  }

  static Future<bool?> update(
    String key,
    String value, {
    bool? authRequired,
  }) async {
    String? result = await _channel.invokeMethod(
      'update',
      {
        'key': key,
        'value': value,
        'auth': authRequired,
      },
    );

    if (kDebugMode) print('Keychain Update Result: $result');
    return result == 'true';
  }
}
