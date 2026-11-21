import 'package:material_ui/material_ui.dart';

import '../../../domain/model/execution/read_request.dart';
import '../../../domain/model/execution/read_value_type.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import 'read_line_choices.dart';
import 'read_line_entry.dart';
import 'read_line_header.dart';
import 'read_line_note.dart';

final class ReadLine extends StatefulWidget {
  final ReadRequest? request;
  final ValueChanged<String> onSubmit;

  const ReadLine({super.key, required this.request, required this.onSubmit});

  @override
  State<ReadLine> createState() => _ReadLineState();
}

final class _ReadLineState extends State<ReadLine> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  @override
  void didUpdateWidget(covariant ReadLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.request, widget.request)) _prefill();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _prefill() {
    final rejected = widget.request?.rejection?.rejectedText ?? '';
    _controller.value = TextEditingValue(
      text: rejected,
      selection: TextSelection(baseOffset: 0, extentOffset: rejected.length),
    );
  }

  void _submit(String text) {
    widget.onSubmit(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    return _ReadLineFrame(
      isRejected: request?.rejection != null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (request != null) ReadLineHeader(request: request),
          ReadLineEntry(
            request: request,
            controller: _controller,
            onSubmit: _submit,
          ),
          if (request != null) ReadLineNote(request: request),
          if (request?.valueType == ReadValueType.boolean)
            ReadLineChoices(onChoose: _submit),
        ],
      ),
    );
  }
}

final class _ReadLineFrame extends StatelessWidget {
  final bool isRejected;
  final Widget child;

  const _ReadLineFrame({required this.isRejected, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final borderColor = isRejected
        ? theme.colors.severities.error.border
        : theme.colors.borders.focus;
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.space2),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.surfaces.brandSubtle,
          borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
          border: Border.all(
            color: borderColor,
            width: BorderMetricsTokens.widthHairline,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.space3),
          child: child,
        ),
      ),
    );
  }
}
