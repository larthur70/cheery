import 'dart:convert';
import 'dart:typed_data';

import 'package:cheery/features/import_clients/data/xlsx_reader.dart';
import 'package:cheery/features/import_clients/domain/import_clients_failure.dart';
import 'package:cheery/features/import_clients/domain/parsed_spreadsheet.dart';
import 'package:csv/csv.dart';

/// Parses CSV and XLSX bytes into a [ParsedSpreadsheet].
abstract final class SpreadsheetParser {
  static const int maxRows = 5000;
  static const int maxBytes = 2 * 1024 * 1024;

  static ParsedSpreadsheet parse({
    required String fileName,
    required Uint8List bytes,
    String? extension,
  }) {
    if (bytes.length > maxBytes) {
      throw const ImportFileTooLargeFailure();
    }
    final kind = _detectKind(
      fileName: fileName,
      extension: extension,
      bytes: bytes,
    );

    switch (kind) {
      case _SpreadsheetKind.csv:
        return _parseCsv(fileName: fileName, bytes: bytes);
      case _SpreadsheetKind.xlsx:
        return _parseExcel(fileName: fileName, bytes: bytes);
      case _SpreadsheetKind.unknown:
        throw const ImportFileInvalidFailure();
    }
  }

  static _SpreadsheetKind _detectKind({
    required String fileName,
    required String? extension,
    required Uint8List bytes,
  }) {
    final ext = (extension ?? _extensionOf(fileName)).toLowerCase();

    if (ext == 'csv' || fileName.toLowerCase().endsWith('.csv')) {
      return _SpreadsheetKind.csv;
    }
    if (ext == 'xlsx' ||
        ext == 'xls' ||
        fileName.toLowerCase().endsWith('.xlsx') ||
        fileName.toLowerCase().endsWith('.xls')) {
      // Legacy .xls is not ZIP/OOXML.
      if ((ext == 'xls' || fileName.toLowerCase().endsWith('.xls')) &&
          !fileName.toLowerCase().endsWith('.xlsx') &&
          !_looksLikeZip(bytes)) {
        throw const ImportFileInvalidFailure(
          'Arquivos .xls antigos não são suportados. Salve como .xlsx ou .csv.',
        );
      }
      return _SpreadsheetKind.xlsx;
    }

    // Web file pickers sometimes omit the extension from the display name.
    if (_looksLikeZip(bytes)) {
      return _SpreadsheetKind.xlsx;
    }
    if (_looksLikeCsvText(bytes)) {
      return _SpreadsheetKind.csv;
    }

    return _SpreadsheetKind.unknown;
  }

  static String _extensionOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return '';
    return fileName.substring(dot + 1);
  }

  /// XLSX is a ZIP archive (`PK` magic).
  static bool _looksLikeZip(Uint8List bytes) {
    return bytes.length >= 4 && bytes[0] == 0x50 && bytes[1] == 0x4B;
  }

  static bool _looksLikeCsvText(Uint8List bytes) {
    if (bytes.isEmpty) return false;
    if (_looksLikeZip(bytes)) return false;
    try {
      final sample = utf8.decode(
        bytes.length > 512 ? bytes.sublist(0, 512) : bytes,
        allowMalformed: true,
      );
      return sample.contains(',') ||
          sample.contains(';') ||
          sample.contains('\t');
    } catch (_) {
      return false;
    }
  }

  static ParsedSpreadsheet _parseCsv({
    required String fileName,
    required Uint8List bytes,
  }) {
    final content = _decodeText(bytes);
    final rows = csv.decode(
      content.replaceAll('\r\n', '\n').replaceAll('\r', '\n'),
    );

    return _fromMatrix(fileName: fileName, matrix: rows);
  }

  static ParsedSpreadsheet _parseExcel({
    required String fileName,
    required Uint8List bytes,
  }) {
    final matrix = XlsxReader.readMatrix(bytes);
    return _fromMatrix(fileName: fileName, matrix: matrix);
  }

  static ParsedSpreadsheet _fromMatrix({
    required String fileName,
    required List<List<dynamic>> matrix,
  }) {
    final nonEmpty = matrix
        .map((row) => row.map((cell) => _cellToString(cell)).toList())
        .where((row) => row.any((cell) => cell.trim().isNotEmpty))
        .toList();

    if (nonEmpty.isEmpty) {
      throw const ImportFileEmptyFailure();
    }

    final headers = nonEmpty.first.map((h) => h.trim()).toList();
    if (headers.every((h) => h.isEmpty)) {
      throw const ImportFileEmptyFailure();
    }

    final dataRows = nonEmpty.skip(1).toList();
    if (dataRows.length > maxRows) {
      throw const ImportFileTooLargeFailure();
    }

    final normalizedRows = dataRows.map((row) {
      final padded = List<String>.from(row);
      while (padded.length < headers.length) {
        padded.add('');
      }
      if (padded.length > headers.length) {
        return padded.sublist(0, headers.length);
      }
      return padded;
    }).toList();

    return ParsedSpreadsheet(
      fileName: fileName,
      headers: headers,
      rows: normalizedRows,
    );
  }

  static String _decodeText(Uint8List bytes) {
    try {
      return utf8.decode(bytes);
    } catch (_) {
      return latin1.decode(bytes);
    }
  }

  static String _cellToString(dynamic cell) {
    if (cell == null) return '';
    if (cell is String) return cell;
    if (cell is num) {
      if (cell is int || cell == cell.roundToDouble()) {
        return cell.round().toString();
      }
      return cell.toString();
    }
    return cell.toString();
  }
}

enum _SpreadsheetKind { csv, xlsx, unknown }
