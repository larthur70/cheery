/// Wizard steps for client import.
enum ImportStep {
  upload,
  mapping,
  review,
  confirmation,
}

extension ImportStepUi on ImportStep {
  int get index => ImportStep.values.indexOf(this);

  String get label => switch (this) {
        ImportStep.upload => 'Upload',
        ImportStep.mapping => 'Mapeamento',
        ImportStep.review => 'Revisão',
        ImportStep.confirmation => 'Confirmação',
      };
}
