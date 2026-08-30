import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cheery/features/import_clients/domain/import_clients_failure.dart';
import 'package:xml/xml.dart';

/// Lightweight XLSX reader that supports absolute relationship targets and
/// `inlineStr` cells (common in files exported by Numbers / some web tools).
///
/// The `excel` package crashes on `Target="/xl/..."` paths — this reader
/// resolves those correctly.
abstract final class XlsxReader {
  static List<List<String>> readMatrix(Uint8List bytes) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw const ImportFileInvalidFailure(
        'Não foi possível ler este Excel. Exporte novamente como .xlsx ou .csv.',
      );
    }

    try {
      final sharedStrings = _parseSharedStrings(archive);
      final sheetPath = _resolveFirstSheetPath(archive);
      final sheetXml = _readXml(archive, sheetPath);
      return _parseSheetData(sheetXml, sharedStrings);
    } on ImportClientsFailure {
      rethrow;
    } catch (_) {
      throw const ImportFileInvalidFailure(
        'Não foi possível ler este Excel. Verifique se o arquivo não está corrompido.',
      );
    }
  }

  static String _resolveFirstSheetPath(Archive archive) {
    final workbook = _readXml(archive, 'xl/workbook.xml');
    final sheets = workbook.findAllElements('sheet').toList();
    if (sheets.isEmpty) {
      throw const ImportFileEmptyFailure();
    }

    final rid = sheets.first.getAttribute('r:id') ??
        sheets.first.getAttribute('id');
    if (rid == null || rid.isEmpty) {
      throw const ImportFileInvalidFailure(
        'Planilha Excel sem referência de aba válida.',
      );
    }

    final rels = _readXml(archive, 'xl/_rels/workbook.xml.rels');
    String? target;
    for (final rel in rels.findAllElements('Relationship')) {
      if (rel.getAttribute('Id') == rid) {
        target = rel.getAttribute('Target');
        break;
      }
    }

    if (target == null || target.isEmpty) {
      throw const ImportFileInvalidFailure(
        'Não foi possível localizar a aba da planilha.',
      );
    }

    return _normalizeSheetPath(target);
  }

  /// Converts relationship targets into archive entry paths.
  ///
  /// Examples:
  /// - `/xl/worksheets/sheet1.xml` → `xl/worksheets/sheet1.xml`
  /// - `worksheets/sheet1.xml` → `xl/worksheets/sheet1.xml`
  /// - `xl/worksheets/sheet1.xml` → `xl/worksheets/sheet1.xml`
  static String _normalizeSheetPath(String target) {
    var path = target.replaceAll('\\', '/');
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    if (!path.startsWith('xl/')) {
      path = 'xl/$path';
    }
    return path;
  }

  static List<String> _parseSharedStrings(Archive archive) {
    final file = _findFile(archive, 'xl/sharedStrings.xml');
    if (file == null) return const [];

    final document = XmlDocument.parse(utf8.decode(file.content as List<int>));
    final values = <String>[];
    for (final si in document.findAllElements('si')) {
      values.add(_textFromSharedString(si));
    }
    return values;
  }

  static String _textFromSharedString(XmlElement si) {
    final texts = si.findAllElements('t');
    if (texts.isEmpty) return '';
    return texts.map((t) => t.innerText).join();
  }

  static List<List<String>> _parseSheetData(
    XmlDocument sheetXml,
    List<String> sharedStrings,
  ) {
    final sheetData = sheetXml.findAllElements('sheetData').firstOrNull;
    if (sheetData == null) {
      throw const ImportFileEmptyFailure();
    }

    final rows = <int, Map<int, String>>{};
    var maxCol = -1;

    for (final rowEl in sheetData.findElements('row')) {
      final rowAttr = rowEl.getAttribute('r');
      final rowIndex = rowAttr != null
          ? (int.tryParse(rowAttr) ?? 0) - 1
          : (rows.keys.isEmpty ? 0 : rows.keys.reduce((a, b) => a > b ? a : b) + 1);
      if (rowIndex < 0) continue;

      final cells = rows.putIfAbsent(rowIndex, () => <int, String>{});

      for (final cellEl in rowEl.findElements('c')) {
        final ref = cellEl.getAttribute('r');
        final colIndex = ref != null ? _columnIndexFromRef(ref) : cells.length;
        if (colIndex < 0) continue;
        if (colIndex > maxCol) maxCol = colIndex;
        cells[colIndex] = _cellValue(cellEl, sharedStrings);
      }
    }

    if (rows.isEmpty || maxCol < 0) {
      throw const ImportFileEmptyFailure();
    }

    final maxRow = rows.keys.reduce((a, b) => a > b ? a : b);
    final matrix = <List<String>>[];
    for (var r = 0; r <= maxRow; r++) {
      final cells = rows[r] ?? const <int, String>{};
      matrix.add([
        for (var c = 0; c <= maxCol; c++) cells[c] ?? '',
      ]);
    }
    return matrix;
  }

  static String _cellValue(XmlElement cell, List<String> sharedStrings) {
    final type = cell.getAttribute('t');

    if (type == 'inlineStr') {
      final texts = cell.findAllElements('t');
      return texts.map((t) => t.innerText).join();
    }

    if (type == 's') {
      final raw = cell.getElement('v')?.innerText ?? '';
      final index = int.tryParse(raw);
      if (index == null || index < 0 || index >= sharedStrings.length) {
        return raw;
      }
      return sharedStrings[index];
    }

    if (type == 'b') {
      final raw = cell.getElement('v')?.innerText ?? '0';
      return raw == '1' || raw.toLowerCase() == 'true' ? 'true' : 'false';
    }

    if (type == 'str' || type == 'e') {
      return cell.getElement('v')?.innerText ?? '';
    }

    // Number / date serial / default
    return cell.getElement('v')?.innerText ?? '';
  }

  /// `A1` → 0, `B1` → 1, `AA2` → 26.
  static int _columnIndexFromRef(String ref) {
    final letters = StringBuffer();
    for (final code in ref.codeUnits) {
      if (code >= 65 && code <= 90) {
        letters.writeCharCode(code);
      } else if (code >= 97 && code <= 122) {
        letters.writeCharCode(code - 32);
      } else {
        break;
      }
    }
    if (letters.isEmpty) return -1;
    var index = 0;
    for (final code in letters.toString().codeUnits) {
      index = index * 26 + (code - 64);
    }
    return index - 1;
  }

  static XmlDocument _readXml(Archive archive, String path) {
    final file = _findFile(archive, path);
    if (file == null) {
      throw ImportFileInvalidFailure(
        'Arquivo Excel incompleto (faltando $path).',
      );
    }
    return XmlDocument.parse(utf8.decode(file.content as List<int>));
  }

  static ArchiveFile? _findFile(Archive archive, String path) {
    final normalized = path.replaceAll('\\', '/');
    for (final file in archive.files) {
      if (!file.isFile) continue;
      final name = file.name.replaceAll('\\', '/');
      if (name == normalized || name.endsWith('/$normalized')) {
        file.decompress();
        return file;
      }
    }
    return null;
  }
}
