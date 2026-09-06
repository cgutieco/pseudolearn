import 'package:pseudolearn_app/domain/ports/text_entry_modality.dart';

final class FakeTextEntryModality implements TextEntryModality {
  @override
  final bool hasOnscreenTextEntry;

  const FakeTextEntryModality({this.hasOnscreenTextEntry = true});
}
