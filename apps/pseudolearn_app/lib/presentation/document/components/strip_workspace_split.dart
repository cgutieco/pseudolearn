import 'package:flutter/widgets.dart';

const double _stripHeightShare = 0.5;

final class StripWorkspaceSplit extends StatelessWidget {
  final Widget strip;
  final Widget workspace;

  const StripWorkspaceSplit({
    super.key,
    required this.strip,
    required this.workspace,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: constraints.maxHeight * _stripHeightShare,
            ),
            child: strip,
          ),
          Expanded(child: workspace),
        ],
      ),
    );
  }
}
