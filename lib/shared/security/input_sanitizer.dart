// ignore_for_file: deprecated_member_use

import 'package:flutter/services.dart';

class InputSanitizer {
  const InputSanitizer._();

  static final RegExp _controlCharacters = RegExp(
    r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]',
  );
  static final RegExp _hiddenUnicodeControls = RegExp(
    '[\u200B-\u200F\u202A-\u202E\u2066-\u2069\uFEFF]',
  );
  static final RegExp _whitespace = RegExp(r'\s+');
  static final RegExp _safeFileCharacters = RegExp(r'[^A-Za-z0-9._-]');
  static final RegExp _safeIdCharacters = RegExp(r'[^A-Za-z0-9_-]');

  static String text(String value, {int maxLength = 160}) {
    final cleaned = value
        .replaceAll(_hiddenUnicodeControls, '')
        .replaceAll(_controlCharacters, '')
        .replaceAll(_whitespace, ' ')
        .trim();
    return _limit(cleaned, maxLength);
  }

  static String search(String value, {int maxLength = 80}) {
    return text(value, maxLength: maxLength);
  }

  static String location(String value) {
    return text(value, maxLength: 120);
  }

  static String safeId(String value, {int maxLength = 80}) {
    return _limit(
      text(value, maxLength: maxLength).replaceAll(_safeIdCharacters, ''),
      maxLength,
    );
  }

  static String fileName(String value, {String fallback = 'cultiva.pdf'}) {
    final name = value
        .split(RegExp(r'[/\\]+'))
        .last
        .replaceAll(_hiddenUnicodeControls, '')
        .replaceAll(_controlCharacters, '')
        .replaceAll(_safeFileCharacters, '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
    final safeName = _limit(name, 80).replaceAll(RegExp(r'^\.+'), '');
    if (safeName.isEmpty) {
      return fallback;
    }
    return safeName.toLowerCase().endsWith('.pdf') ? safeName : '$safeName.pdf';
  }

  static String phoneNumber(String value) {
    final buffer = StringBuffer();
    for (var index = 0; index < value.length; index++) {
      final char = value[index];
      final isDigit = char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
      if (isDigit || (char == '+' && buffer.isEmpty)) {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  static double? finiteDouble(String value, {double? min, double? max}) {
    final parsed = double.tryParse(text(value).replaceAll(',', '.'));
    if (parsed == null || !parsed.isFinite) {
      return null;
    }
    if (min != null && parsed < min) {
      return null;
    }
    if (max != null && parsed > max) {
      return null;
    }
    return parsed;
  }

  static bool isValidLocation(String value) {
    final sanitized = location(value);
    if (sanitized.length < 2) {
      return false;
    }
    return RegExp(r"^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ0-9 .,'-]+$").hasMatch(sanitized);
  }

  static String _limit(String value, int maxLength) {
    if (maxLength <= 0 || value.length <= maxLength) {
      return value;
    }
    return value.substring(0, maxLength);
  }
}

class SafeTextInputFormatter extends TextInputFormatter {
  const SafeTextInputFormatter({this.maxLength = 160});

  final int maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final sanitized = InputSanitizer.text(newValue.text, maxLength: maxLength);
    final requestedOffset = newValue.selection.end < 0
        ? sanitized.length
        : newValue.selection.end;
    final selectionOffset = sanitized.length < requestedOffset
        ? sanitized.length
        : requestedOffset;
    return TextEditingValue(
      text: sanitized,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  const DecimalTextInputFormatter({this.maxLength = 12});

  final int maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final buffer = StringBuffer();
    for (var index = 0; index < newValue.text.length; index++) {
      final char = newValue.text[index];
      final code = char.codeUnitAt(0);
      if ((code >= 48 && code <= 57) || char == '.' || char == ',') {
        buffer.write(char);
      }
      if (buffer.length >= maxLength) {
        break;
      }
    }
    final text = buffer.toString();
    final requestedOffset = newValue.selection.end < 0
        ? text.length
        : newValue.selection.end;
    final selectionOffset = text.length < requestedOffset
        ? text.length
        : requestedOffset;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }
}
