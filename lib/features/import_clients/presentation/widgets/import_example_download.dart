import 'package:cheery/features/import_clients/data/import_example_template.dart';
import 'package:cheery/features/import_clients/presentation/widgets/download_bytes_stub.dart'
    if (dart.library.html) 'package:cheery/features/import_clients/presentation/widgets/download_bytes_web.dart'
    as download;

/// Triggers a browser download of the example CSV template (web only).
void downloadImportExampleTemplate() {
  download.downloadBytes(
    bytes: ImportExampleTemplate.bytes,
    fileName: ImportExampleTemplate.fileName,
    mimeType: 'text/csv;charset=utf-8',
  );
}
