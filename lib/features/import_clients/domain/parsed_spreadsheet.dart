/// Result of reading a CSV or Excel file.
class ParsedSpreadsheet {
  const ParsedSpreadsheet({
    required this.fileName,
    required this.headers,
    required this.rows,
  });

  final String fileName;
  final List<String> headers;

  /// Data rows only (header excluded). Each row is a list of cell strings.
  final List<List<String>> rows;

  int get rowCount => rows.length;
}
