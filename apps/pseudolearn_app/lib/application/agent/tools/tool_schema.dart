Map<String, Object?> objectSchema(
  Map<String, Map<String, Object?>> properties, {
  List<String> required = const [],
}) => {
  'type': 'object',
  'properties': properties,
  'required': required,
  'additionalProperties': false,
};

Map<String, Object?> stringProperty(String description, {List<String>? values}) => {
  'type': 'string',
  'description': description,
  'enum': ?values,
};

Map<String, Object?> integerProperty(String description) => {
  'type': 'integer',
  'description': description,
};

Map<String, Object?> stringListProperty(String description) => {
  'type': 'array',
  'items': {'type': 'string'},
  'description': description,
};

Map<String, Object?> objectListProperty(String description, Map<String, Object?> item) => {
  'type': 'array',
  'items': item,
  'description': description,
};

const List<String> profileNames = ['classicSpanish', 'english'];
