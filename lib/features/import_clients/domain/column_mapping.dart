import 'package:cheery/features/import_clients/domain/import_column_field.dart';

/// Maps spreadsheet header indexes to import fields.
class ColumnMapping {
  const ColumnMapping({
    this.nameIndex,
    this.phoneIndex,
    this.birthDateIndex,
    this.templateIndex,
    this.automaticIndex,
  });

  final int? nameIndex;
  final int? phoneIndex;
  final int? birthDateIndex;
  final int? templateIndex;
  final int? automaticIndex;

  bool get isComplete =>
      nameIndex != null && phoneIndex != null && birthDateIndex != null;

  int? indexFor(ImportColumnField field) => switch (field) {
        ImportColumnField.name => nameIndex,
        ImportColumnField.phone => phoneIndex,
        ImportColumnField.birthDate => birthDateIndex,
        ImportColumnField.template => templateIndex,
        ImportColumnField.automatic => automaticIndex,
      };

  ColumnMapping copyWithField(ImportColumnField field, int? index) {
    return switch (field) {
      ImportColumnField.name => ColumnMapping(
          nameIndex: index,
          phoneIndex: phoneIndex,
          birthDateIndex: birthDateIndex,
          templateIndex: templateIndex,
          automaticIndex: automaticIndex,
        ),
      ImportColumnField.phone => ColumnMapping(
          nameIndex: nameIndex,
          phoneIndex: index,
          birthDateIndex: birthDateIndex,
          templateIndex: templateIndex,
          automaticIndex: automaticIndex,
        ),
      ImportColumnField.birthDate => ColumnMapping(
          nameIndex: nameIndex,
          phoneIndex: phoneIndex,
          birthDateIndex: index,
          templateIndex: templateIndex,
          automaticIndex: automaticIndex,
        ),
      ImportColumnField.template => ColumnMapping(
          nameIndex: nameIndex,
          phoneIndex: phoneIndex,
          birthDateIndex: birthDateIndex,
          templateIndex: index,
          automaticIndex: automaticIndex,
        ),
      ImportColumnField.automatic => ColumnMapping(
          nameIndex: nameIndex,
          phoneIndex: phoneIndex,
          birthDateIndex: birthDateIndex,
          templateIndex: templateIndex,
          automaticIndex: index,
        ),
    };
  }

  /// Clears any other field that already points at [index].
  ColumnMapping withExclusive(ImportColumnField field, int? index) {
    var next = this;
    if (index != null) {
      for (final other in ImportColumnField.values) {
        if (other == field) continue;
        if (next.indexFor(other) == index) {
          next = next.copyWithField(other, null);
        }
      }
    }
    return next.copyWithField(field, index);
  }
}
