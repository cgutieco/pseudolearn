import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/model/reference/reference_figure.dart';
import '../theme/app_theme.dart';
import 'figure_color_mapper.dart';

const double referenceFigureMaxWidth = 420;

final class ReferenceSvg extends StatelessWidget {
  final String svg;
  final String label;

  const ReferenceSvg({super.key, required this.svg, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: referenceFigureMaxWidth),
        child: AspectRatio(
          aspectRatio: svgAspectRatio(svg),
          child: SvgPicture.string(
            svg,
            fit: BoxFit.contain,
            semanticsLabel: label,
            colorMapper: FigureColorMapper.of(theme),
          ),
        ),
      ),
    );
  }
}
