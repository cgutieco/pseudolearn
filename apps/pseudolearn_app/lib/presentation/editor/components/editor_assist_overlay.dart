import 'package:flutter/material.dart';
import '../../../domain/model/completion/completion_item.dart';
import '../../theme/tokens/component_metrics.dart';
import 'editor_completion_popup.dart';
import 'editor_ghost_text.dart';
import 'editor_assist_geometry.dart';

final class EditorAssistOverlay extends StatelessWidget {
  final EditorAssistAnchor? anchor;
  final String? ghostText;
  final List<CompletionItem> candidates;
  final int selectedIndex;
  final ValueChanged<CompletionItem> onSelected;

  const EditorAssistOverlay({
    super.key,
    required this.anchor,
    required this.ghostText,
    required this.candidates,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final geometry = anchor;
    if (geometry == null) return const SizedBox.shrink();
    final ghost = ghostText;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (ghost != null && geometry.ghostOrigin != null)
          Positioned(
            left: geometry.ghostOrigin!.dx,
            top: geometry.ghostOrigin!.dy,
            child: EditorGhostText(
              text: ghost,
              typography: geometry.typography,
            ),
          ),
        if (candidates.isNotEmpty)
          _PopupPlacement(
            anchor: geometry.caret,
            rowCount: candidates.length,
            child: EditorCompletionPopup(
              candidates: candidates,
              selectedIndex: selectedIndex,
              onSelected: onSelected,
            ),
          ),
      ],
    );
  }
}

final class _PopupPlacement extends StatelessWidget {
  final Rect anchor;
  final int rowCount;
  final Widget child;

  const _PopupPlacement({
    required this.anchor,
    required this.rowCount,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final spot = _popupSpot(anchor, rowCount, constraints.biggest);
          return Stack(
            children: [Positioned(left: spot.dx, top: spot.dy, child: child)],
          );
        },
      ),
    );
  }
}

Offset _popupSpot(Rect anchor, int rowCount, Size available) {
  final height = rowCount * ComponentMetricsTokens.editorCompletionRowHeight;
  const gap = ComponentMetricsTokens.editorCompletionPopupGap;
  const width = ComponentMetricsTokens.editorCompletionPopupWidth;
  final below = anchor.bottom + gap;
  final top = below + height <= available.height
      ? below
      : (anchor.top - gap - height).clamp(0.0, double.infinity);
  final left = anchor.left.clamp(
    0.0,
    (available.width - width).clamp(0.0, double.infinity),
  );
  return Offset(left, top);
}
