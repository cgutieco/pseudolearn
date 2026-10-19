final class RustViewLiteral {
  final String type;
  final String value;

  const RustViewLiteral({required this.type, required this.value});
}

final class RustViewSemantics {
  final List<String> operators;
  final String? operator;
  final RustViewLiteral? literal;
  final String? builtin;
  final String? receiver;
  final bool withoutNewline;
  final bool superConstructor;
  final String? primitive;

  const RustViewSemantics({
    this.operators = const [],
    this.operator,
    this.literal,
    this.builtin,
    this.receiver,
    this.withoutNewline = false,
    this.superConstructor = false,
    this.primitive,
  });

  static const RustViewSemantics none = RustViewSemantics();

  factory RustViewSemantics.fromJson(Map<String, Object?> node) {
    final literal = node['literal'];
    return RustViewSemantics(
      operators: [
        for (final identity in node['operators'] as List<Object?>? ?? const [])
          identity as String,
      ],
      operator: node['operator'] as String?,
      literal: literal is Map<String, Object?>
          ? RustViewLiteral(
              type: literal['type'] as String,
              value: literal['value'] as String,
            )
          : null,
      builtin: node['builtin'] as String?,
      receiver: node['receiver'] as String?,
      withoutNewline: node['without_newline'] == true,
      superConstructor: node['super_constructor'] == true,
      primitive: node['primitive'] as String?,
    );
  }
}
