import 'dart:typed_data';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../../security/input_sanitizer.dart';

Future<void> savePdfBytes({
  required Uint8List bytes,
  required String fileName,
}) async {
  final safeFileName = InputSanitizer.fileName(fileName);
  final blob = web.Blob(
    <JSAny>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/pdf'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = safeFileName
    ..style.display = 'none';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}
