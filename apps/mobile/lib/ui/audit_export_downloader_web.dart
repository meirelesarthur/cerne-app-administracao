import 'dart:js_interop';

import 'package:web/web.dart' as web;

bool downloadTextFile({
  required String filename,
  required String mimeType,
  required String content,
}) {
  final blob = web.Blob(
    <web.BlobPart>[content.toJS].toJS,
    web.BlobPropertyBag(type: mimeType),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  anchor.click();
  web.URL.revokeObjectURL(url);
  return true;
}
