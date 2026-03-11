import 'dart:typed_data';

import 'pdf_download_service.dart';

Future<void> savePdfBytes({
  required Uint8List bytes,
  required String fileName,
}) async {
  throw const PdfDownloadException(
    'La descarga de PDF no está disponible en esta plataforma.',
  );
}
