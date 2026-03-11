import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import 'pdf_download_service_impl.dart';

class PdfDownloadService {
  Future<void> downloadAssetPdf({
    required String assetPath,
    required String fileName,
  }) async {
    final bytes = await loadPdfBytes(assetPath);
    await savePdfBytes(bytes: bytes, fileName: fileName);
  }
}

class PdfDownloadException implements Exception {
  const PdfDownloadException(this.message);

  final String message;
}

Future<Uint8List> loadPdfBytes(String assetPath) async {
  try {
    final data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  } catch (_) {
    throw PdfDownloadException(
      'No se encontró el PDF en $assetPath. Agrega el archivo en assets/pdfs/.',
    );
  }
}
