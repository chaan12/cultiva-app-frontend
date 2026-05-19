import 'dart:convert';

class SafeJson {
  const SafeJson._();

  static Object? decode(String raw, {int maxBytes = 512000}) {
    if (raw.length > maxBytes) {
      throw const FormatException('JSON demasiado grande.');
    }
    return jsonDecode(raw);
  }

  static Map<String, dynamic> object(String raw, {int maxBytes = 512000}) {
    final decoded = decode(raw, maxBytes: maxBytes);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('JSON inválido.');
    }
    return decoded;
  }

  static List<dynamic> list(String raw, {int maxBytes = 512000}) {
    final decoded = decode(raw, maxBytes: maxBytes);
    if (decoded is! List<dynamic>) {
      throw const FormatException('JSON inválido.');
    }
    return decoded;
  }

  static Map<String, dynamic>? mapAt(Map<String, dynamic> map, String key) {
    final value = map[key];
    return value is Map<String, dynamic> ? value : null;
  }

  static List<dynamic> listAt(Map<String, dynamic> map, String key) {
    final value = map[key];
    return value is List<dynamic> ? value : const <dynamic>[];
  }
}

class SafeJsonEncode {
  const SafeJsonEncode._();

  static String object(Map<String, Object?> value) {
    return jsonEncode(value);
  }

  static String list(List<Object?> value) {
    return jsonEncode(value);
  }
}
