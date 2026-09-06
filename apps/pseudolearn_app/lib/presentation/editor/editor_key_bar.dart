import 'package:flutter/material.dart';
import '../../domain/model/completion/completion_item.dart';
import '../../domain/model/editor/editor_key.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/border_metrics.dart';
import '../theme/tokens/component_metrics.dart';
import 'components/editor_key_cap.dart';
import 'components/editor_template_row.dart';

final class EditorKeyBar extends StatefulWidget {
  final List<EditorKey> keys;
  final List<CompletionItem> templates;
  final ValueChanged<EditorKey> onKeyPressed;

  const EditorKeyBar({
    super.key,
    required this.keys,
    required this.templates,
    required this.onKeyPressed,
  });

  @override
  State<EditorKeyBar> createState() => _EditorKeyBarState();
}

final class _EditorKeyBarState extends State<EditorKeyBar> {
  bool _showsTemplates = false;

  void _toggleTemplates() => setState(() => _showsTemplates = !_showsTemplates);

  void _pressTemplate(CompletionItem item) {
    widget.onKeyPressed(EditorKey.template(
      label: item.label,
      insertion: item.template,
      caretOffset: item.caretOffset,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return _BarSurface(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showsTemplates && widget.templates.isNotEmpty)
            EditorTemplateRow(
              templates: widget.templates,
              onTemplateSelected: _pressTemplate,
            ),
          _KeyRow(
            keys: widget.keys,
            showsTemplates: _showsTemplates,
            onKeyPressed: widget.onKeyPressed,
            onToggleTemplates: _toggleTemplates,
          ),
        ],
      ),
    );
  }
}

final class _BarSurface extends StatelessWidget {
  final Widget child;

  const _BarSurface({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        border: Border(
          top: BorderSide(
            color: theme.colors.borders.subtle,
            width: BorderMetricsTokens.widthHairline,
          ),
        ),
      ),
      child: child,
    );
  }
}

final class _KeyRow extends StatelessWidget {
  final List<EditorKey> keys;
  final bool showsTemplates;
  final ValueChanged<EditorKey> onKeyPressed;
  final VoidCallback onToggleTemplates;

  const _KeyRow({
    required this.keys,
    required this.showsTemplates,
    required this.onKeyPressed,
    required this.onToggleTemplates,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ComponentMetricsTokens.editorKeyBarContainerHeight,
      child: Row(
        children: [
          _TemplatesToggle(
              isOpen: showsTemplates, onPressed: onToggleTemplates),
          ...keys.map((key) => Expanded(
                child: EditorKeyCap(
                    editorKey: key, onPressed: () => onKeyPressed(key)),
              )),
        ],
      ),
    );
  }
}

final class _TemplatesToggle extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onPressed;

  const _TemplatesToggle({required this.isOpen, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: isOpen ? l10n.editorKeyTemplatesHide : l10n.editorKeyTemplatesShow,
      onTap: onPressed,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: ComponentMetricsTokens.editorKeyBarContainerHeight,
          child: Center(
            child: Icon(
              isOpen ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
              color: theme.colors.text.secondary,
            ),
          ),
        ),
      ),
    );
  }
}
