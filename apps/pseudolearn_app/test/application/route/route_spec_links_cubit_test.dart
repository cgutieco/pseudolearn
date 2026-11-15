import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/route/route_spec_links_cubit.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_edition.dart';
import 'package:pseudolearn_app/domain/model/route/route_toc.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../fakes/fake_route_repository.dart';
import '../../fakes/route_fixtures.dart';

const ReferenceEdition _spanish = ReferenceEdition(
  language: UiLanguageId.spanish,
  profile: SyntaxProfileId.classicSpanish,
);

const ReferenceEdition _english = ReferenceEdition(
  language: UiLanguageId.english,
  profile: SyntaxProfileId.english,
);

const Map<String, List<String>> _links = {
  'control.si': ['inicio.primero', 'imperativo.segundo'],
  'control.mientras': ['imperativo.segundo', 'no.existe'],
  'tipos.vacio': [],
};

List<String> _ids(List<RouteLessonEntry> lessons) => [for (final lesson in lessons) lesson.id];

void main() {
  test('maps each section to the lessons of the route that link it', () async {
    final cubit = RouteSpecLinksCubit(repository: FakeRouteRepository(toc: sampleToc, specLinks: _links));

    await cubit.load(_spanish);

    expect(cubit.state.edition, _spanish);
    expect(_ids(cubit.state.lessonsOf('control.si')), ['inicio.primero', 'imperativo.segundo']);
    expect(cubit.state.lessonsOf('control.si').first.number, sampleToc.lessons.first.number);
  });

  test('skips lesson ids that the route does not publish', () async {
    final cubit = RouteSpecLinksCubit(repository: FakeRouteRepository(toc: sampleToc, specLinks: _links));

    await cubit.load(_spanish);

    expect(_ids(cubit.state.lessonsOf('control.mientras')), ['imperativo.segundo']);
  });

  test('a section without links, or unknown, has no lessons', () async {
    final cubit = RouteSpecLinksCubit(repository: FakeRouteRepository(toc: sampleToc, specLinks: _links));

    await cubit.load(_spanish);

    expect(cubit.state.lessonsOf('tipos.vacio'), isEmpty);
    expect(cubit.state.lessonsOf('x'), isEmpty);
  });

  test('a missing route index leaves every section without lessons', () async {
    final cubit = RouteSpecLinksCubit(repository: FakeRouteRepository(specLinks: _links, failToc: true));

    await cubit.load(_spanish);

    expect(cubit.state.edition, _spanish);
    expect(cubit.state.lessonsBySection, isEmpty);
  });

  test('missing section links leave every section without lessons', () async {
    final cubit = RouteSpecLinksCubit(repository: FakeRouteRepository(toc: sampleToc, failSpecLinks: true));

    await cubit.load(_spanish);

    expect(cubit.state.lessonsBySection, isEmpty);
  });

  test('loads each edition once and reloads when the edition changes', () async {
    final repository = FakeRouteRepository(toc: sampleToc, specLinks: _links);
    final cubit = RouteSpecLinksCubit(repository: repository);

    await cubit.load(_spanish);
    await cubit.load(_spanish);
    expect(repository.requestedEditions, [_spanish]);

    await cubit.load(_english);
    expect(repository.requestedEditions, [_spanish, _english]);
    expect(cubit.state.edition, _english);
  });

  test('an empty route index maps nothing', () {
    expect(lessonsBySection(_links, const RouteToc.empty()), {
      'control.si': <RouteLessonEntry>[],
      'control.mientras': <RouteLessonEntry>[],
      'tipos.vacio': <RouteLessonEntry>[],
    });
    expect(lessonsBySection(const {}, sampleToc), isEmpty);
  });
}
