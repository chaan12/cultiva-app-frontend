import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import '../../security/input_sanitizer.dart';
import 'pdf_download_service_impl.dart';

class PdfDownloadService {
  Future<void> downloadAssetPdf({
    required String assetPath,
    required String fileName,
  }) async {
    final bytes = await loadPdfBytes(assetPath);
    await savePdfBytes(
      bytes: bytes,
      fileName: InputSanitizer.fileName(fileName),
    );
  }
}

class PdfDownloadException implements Exception {
  const PdfDownloadException(this.message);

  final String message;
}

Future<Uint8List> loadPdfBytes(String assetPath) async {
  if (!_isAllowedPdfAsset(assetPath)) {
    throw const PdfDownloadException('No se pudo preparar el PDF.');
  }
  try {
    final data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  } catch (_) {
    throw const PdfDownloadException('No se pudo preparar el PDF.');
  }
}

bool _isAllowedPdfAsset(String assetPath) {
  if (!assetPath.startsWith('assets/pdfs/') ||
      !assetPath.endsWith('.pdf') ||
      assetPath.contains('..')) {
    return false;
  }
  final fileName = assetPath.substring('assets/pdfs/'.length);
  if (fileName.length <= 4 || fileName.length > 120) {
    return false;
  }
  for (var index = 0; index < fileName.length; index++) {
    final code = fileName.codeUnitAt(index);
    final isUppercaseLetter = code >= 65 && code <= 90;
    final isLowercaseLetter = code >= 97 && code <= 122;
    final isDigit = code >= 48 && code <= 57;
    final isAllowedSymbol =
        code == 32 || code == 45 || code == 95 || code == 46;
    if (!isUppercaseLetter &&
        !isLowercaseLetter &&
        !isDigit &&
        !isAllowedSymbol) {
      return false;
    }
  }
  return true;
}
