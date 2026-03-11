import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'pdf_download_service.dart';

Future<void> savePdfBytes({
  required Uint8List bytes,
  required String fileName,
}) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  final result = await OpenFilex.open(file.path);
  if (result.type != ResultType.done) {
    throw PdfDownloadException(
      'No se pudo abrir el PDF generado (${result.message}).',
    );
  }
}
