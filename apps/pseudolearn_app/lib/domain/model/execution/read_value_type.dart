enum ReadValueType {
  integer,
  real,
  boolean,
  character,
  text;

  static ReadValueType? fromWireName(Object? name) => switch (name) {
    'entero' => integer,
    'real' => real,
    'logico' => boolean,
    'caracter' => character,
    'cadena' => text,
    _ => null,
  };
}
