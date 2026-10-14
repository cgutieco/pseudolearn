import 'package:pseudolearn_core/pseudolearn_core.dart';

Map<String, Object?> stateView(
    EnvironmentSnapshot? snapshot, LanguageProfile profile) {
  final objects = <String, Object?>{};
  final view = _StateView(profile, objects);
  final frames = [
    for (final frame in snapshot?.frames ?? const <FrameSnapshot>[])
      view.frame(frame)
  ];
  return {'marcos': frames, 'objetos': objects};
}

final class _StateView {
  final LanguageProfile profile;
  final Map<String, Object?> objects;

  _StateView(this.profile, this.objects);

  Map<String, Object?> frame(FrameSnapshot frame) {
    final receiver = frame.receiver;
    return {
      'unidad': frame.subroutineName,
      if (receiver != null) 'receptor': reference(receiver),
      'variables': {
        for (final variable in frame.variables)
          variable.name: variable.hasValue && variable.value != null
              ? value(variable.value!)
              : const {'sin_valor': true},
      },
    };
  }

  Map<String, Object?> value(RuntimeValue value) => switch (value) {
        IntegerValue(:final value) => {'valor': value.toString()},
        RealValue(:final value) => {'valor': value.toString()},
        BooleanValue(:final value) => {
            'valor': profile.formatTokenType(
                value ? TokenType.booleanTrue : TokenType.booleanFalse)
          },
        CharacterValue(:final value) => {'valor': value},
        StringValue(:final value) => {'valor': value},
        ObjectValue() => reference(value),
      };

  Map<String, Object?> reference(ObjectValue object) {
    final key = '${object.instance.id}';
    if (!objects.containsKey(key)) {
      objects[key] = null;
      objects[key] = {
        'clase': object.instance.classSymbol.name,
        'campos': {
          for (final field in object.instance.fieldEntries)
            field.key: field.value.hasValue
                ? value(field.value.value)
                : const {'sin_valor': true},
        },
      };
    }
    return {'ref': object.instance.id};
  }
}
