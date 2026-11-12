import 'package:flutter/widgets.dart';

final class UserExerciseFieldSpec {
  final String name;
  final String label;
  final TextEditingController controller;
  final bool isRequired;
  final String helper;
  final String? placeholder;
  final int lines;
  final bool isCode;

  const UserExerciseFieldSpec({
    required this.name,
    required this.label,
    required this.controller,
    required this.isRequired,
    required this.helper,
    this.placeholder,
    this.lines = 1,
    this.isCode = false,
  });
}
