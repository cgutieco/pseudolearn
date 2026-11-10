import 'package:flutter/material.dart';
import '../shell/design_canvas.dart';
import '../shell/device_class.dart';
import 'agent_chat_panel.dart';

const double _bottomPanelHeightFactor = 0.92;
const double _sidePanelWidthFactor = 0.36;

void openAgentChat(BuildContext context) {
  showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    pageBuilder: (_, _, _) => const AgentChatPlacement(),
  );
}

final class AgentChatPlacement extends StatelessWidget {
  const AgentChatPlacement({super.key});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: canvas.keyboardInset),
        child: switch (canvas.deviceClass) {
          DeviceClass.compact => const _BottomPlacement(),
          DeviceClass.medium || DeviceClass.expanded => const _SidePlacement(),
        },
      ),
    );
  }
}

final class _BottomPlacement extends StatelessWidget {
  const _BottomPlacement();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(heightFactor: _bottomPanelHeightFactor, child: AgentChatPanel()),
    );
  }
}

final class _SidePlacement extends StatelessWidget {
  const _SidePlacement();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(heightFactor: 1, widthFactor: _sidePanelWidthFactor, child: AgentChatPanel()),
    );
  }
}
