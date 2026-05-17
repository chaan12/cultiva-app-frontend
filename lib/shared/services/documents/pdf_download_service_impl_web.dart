import 'dart:typed_data';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<void> savePdfBytes({
  required Uint8List bytes,
  required String fileName,
}) async {
  final safeFileName = fileName
      .split((r'[/\\]'))
      .last
      .replaceAll((r'[^A-Za-z0-9._-]'), '_');
  final blob = web.Blob(
    <JSAny>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/pdf'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = safeFileName.isEmpty ? 'cultiva.pdf' : safeFileName
    ..style.display = 'none';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}
