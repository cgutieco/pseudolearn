import 'package:flutter/material.dart';
import 'app_list_item.dart';

final class AppRadioOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const AppRadioOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

final class AppRadioList<T> extends StatelessWidget {
  final List<AppRadioOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  const AppRadioList({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final option in options)
          AppListItem(
            icon: option.icon,
            label: option.label,
            trailing: option.value == selectedValue
                ? AppListItemTrailingKind.check
                : AppListItemTrailingKind.none,
            selected: option.value == selectedValue,
            onTap: () => onSelected(option.value),
          ),
      ],
    );
  }
}
