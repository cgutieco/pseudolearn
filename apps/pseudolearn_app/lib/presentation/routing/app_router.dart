import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../document/document_page.dart';
import '../exercises/user_exercise_editor_page.dart';
import '../dashboard/dashboard_page.dart';
import '../knowledge/knowledge_page.dart';
import '../library/library_page.dart';
import '../onboarding/onboarding_page.dart';
import '../reference/reference_section_page.dart';
import '../route/route_exercise_page.dart';
import '../route/route_lesson_page.dart';
import '../settings/account/account_page.dart';
import '../settings/contact/contact_support_page.dart';
import '../settings/diagram/diagram_settings_page.dart';
import '../settings/editor/editor_settings_page.dart';
import '../settings/language/language_settings_page.dart';
import '../settings/settings_overview_page.dart';
import '../settings/theme/theme_settings_page.dart';
import '../shell/adaptive_shell.dart';

GoRouter buildAppRouter({String initialLocation = '/biblioteca'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(key: ValueKey('feature:onboarding')),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AdaptiveShell(navigationShell: navigationShell),
        branches: [
          _libraryBranch(),
          _knowledgeBranch(),
          _progressBranch(),
          _settingsBranch(),
        ],
      ),
    ],
  );
}

StatefulShellBranch _knowledgeBranch() {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: '/conocimiento',
        builder: (context, state) => const KnowledgePage(key: ValueKey('feature:knowledge')),
        routes: [
          GoRoute(
            path: 'especificacion/:id',
            builder: (context, state) => ReferenceSectionPage(
              key: const ValueKey('feature:specification'),
              sectionId: state.pathParameters['id'] ?? '',
              anchor: state.uri.queryParameters['anchor'],
            ),
          ),
          GoRoute(
            path: 'ruta/:leccion',
            builder: (context, state) => RouteLessonPage(
              key: const ValueKey('feature:route-lesson'),
              lessonId: state.pathParameters['leccion'] ?? '',
            ),
            routes: [
              GoRoute(
                path: ':ejercicio',
                builder: (context, state) => RouteExercisePage(
                  key: const ValueKey('feature:route-exercise'),
                  lessonId: state.pathParameters['leccion'] ?? '',
                  exerciseId: state.pathParameters['ejercicio'] ?? '',
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

StatefulShellBranch _libraryBranch() {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: '/biblioteca',
        builder: (context, state) => const LibraryPage(key: ValueKey('feature:library')),
        routes: [
          GoRoute(
            path: 'documento/:id',
            builder: (context, state) => DocumentPage(
              key: const ValueKey('feature:editor'),
              documentId: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(
            path: 'ejercicio/:id',
            builder: (context, state) => UserExerciseEditorPage(
              exerciseId: state.pathParameters['id'] ?? '',
            ),
          ),
        ],
      ),
    ],
  );
}

StatefulShellBranch _progressBranch() {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: '/progreso',
        builder: (context, state) => const DashboardPage(key: ValueKey('feature:progress')),
      ),
    ],
  );
}

StatefulShellBranch _settingsBranch() {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: '/ajustes',
        builder: (context, state) => const SettingsOverviewPage(key: ValueKey('feature:settings')),
        routes: [
          GoRoute(
            path: 'cuenta',
            builder: (context, state) => const AccountPage(key: ValueKey('feature:settings-account')),
          ),
          GoRoute(
            path: 'idioma',
            builder: (context, state) => const LanguageSettingsPage(key: ValueKey('feature:settings-language')),
          ),
          GoRoute(
            path: 'tema',
            builder: (context, state) => const ThemeSettingsPage(key: ValueKey('feature:settings-theme')),
          ),
          GoRoute(
            path: 'diagramas',
            builder: (context, state) => const DiagramSettingsPage(key: ValueKey('feature:settings-diagrams')),
          ),
          GoRoute(
            path: 'editor',
            builder: (context, state) => const EditorSettingsPage(key: ValueKey('feature:settings-editor')),
          ),
          GoRoute(
            path: 'contacto',
            builder: (context, state) => const ContactSupportPage(key: ValueKey('feature:settings-contact')),
          ),
        ],
      ),
    ],
  );
}
