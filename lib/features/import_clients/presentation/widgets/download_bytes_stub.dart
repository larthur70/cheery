import 'dart:typed_data';

/// Stub for non-web platforms — no-op.
void downloadBytes({
  required Uint8List bytes,
  required String fileName,
  String mimeType = 'application/octet-stream',
}) {}
