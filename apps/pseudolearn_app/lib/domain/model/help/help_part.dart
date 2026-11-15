import 'package:equatable/equatable.dart';

enum HelpPartKind { word, slot }

final class HelpPart extends Equatable {
  final HelpPartKind kind;
  final String name;
  final String text;

  const HelpPart({required this.kind, required this.name, required this.text});

  @override
  List<Object?> get props => [kind, name, text];
}

enum HelpCategory { block, instruction, symbol, function, type, value }
