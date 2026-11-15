import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../application/route/route_spec_links_cubit.dart';
import '../../application/route/route_spec_links_state.dart';
import '../../domain/model/reference/reference_run.dart';
import '../../domain/model/route/route_toc.dart';
import '../components/button/app_button.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';
import 'reference_edition_resolver.dart';

final class ReferenceRouteLinksFooter extends StatefulWidget {
  final String sectionId;

  const ReferenceRouteLinksFooter({super.key, required this.sectionId});

  @override
  State<ReferenceRouteLinksFooter> createState() =>
      _ReferenceRouteLinksFooterState();
}

final class _ReferenceRouteLinksFooterState
    extends State<ReferenceRouteLinksFooter> {
  bool _available = false;

  @override
  void initState() {
    super.initState();
    _available =
        context
            .findAncestorWidgetOfExactType<
              BlocProvider<RouteSpecLinksCubit>
            >() !=
        null;
    if (_available) {
      context.read<RouteSpecLinksCubit>().load(
        currentReferenceEdition(context),
      );
    }
  }

  void _openLesson(String lessonId) =>
      context.push('/conocimiento/ruta/$lessonId');

  @override
  Widget build(BuildContext context) {
    if (!_available) return const SizedBox.shrink();
    return BlocBuilder<RouteSpecLinksCubit, RouteSpecLinksState>(
      builder: (context, state) => ReferenceRouteLinks(
        lessons: state.lessonsOf(widget.sectionId),
        onOpenLesson: _openLesson,
      ),
    );
  }
}

final class ReferenceRouteLinks extends StatelessWidget {
  final List<RouteLessonEntry> lessons;
  final ValueChanged<String> onOpenLesson;

  const ReferenceRouteLinks({
    super.key,
    required this.lessons,
    required this.onOpenLesson,
  });

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(l10n.routeLearnInRoute, variant: AppTextVariant.heading4),
          const SizedBox(height: SpacingTokens.space2),
          _LessonButtons(lessons: lessons, onOpenLesson: onOpenLesson),
        ],
      ),
    );
  }
}

final class _LessonButtons extends StatelessWidget {
  final List<RouteLessonEntry> lessons;
  final ValueChanged<String> onOpenLesson;

  const _LessonButtons({required this.lessons, required this.onOpenLesson});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: SpacingTokens.space2,
      runSpacing: SpacingTokens.space2,
      children: [
        for (final lesson in lessons)
          AppButton(
            label: '${lesson.number} · ${plainTextOf(lesson.title)}',
            variant: AppButtonVariant.secondary,
            icon: Icons.school_outlined,
            onPressed: () => onOpenLesson(lesson.id),
          ),
      ],
    );
  }
}
