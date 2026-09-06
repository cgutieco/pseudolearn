import 'package:flutter/material.dart';
import 'app_text_field.dart';

final class AppSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const AppSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      placeholder: hintText,
      leadingIcon: Icons.search,
      onClear: onClear,
      onChanged: onChanged,
    );
  }
}
