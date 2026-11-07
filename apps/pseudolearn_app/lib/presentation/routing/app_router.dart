import 'package:go_router/go_router.dart';
import '../document/document_page.dart';
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
        builder: (context, state) => const OnboardingPage(),
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
        builder: (context, state) => const KnowledgePage(),
        routes: [
          GoRoute(
            path: 'especificacion/:id',
            builder: (context, state) => ReferenceSectionPage(
              sectionId: state.pathParameters['id'] ?? '',
              anchor: state.uri.queryParameters['anchor'],
            ),
          ),
          GoRoute(
            path: 'ruta/:leccion',
            builder: (context, state) => RouteLessonPage(
              lessonId: state.pathParameters['leccion'] ?? '',
            ),
            routes: [
              GoRoute(
                path: ':ejercicio',
                builder: (context, state) => RouteExercisePage(
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
        builder: (context, state) => const LibraryPage(),
        routes: [
          GoRoute(
            path: 'documento/:id',
            builder: (context, state) => DocumentPage(
              documentId: state.pathParameters['id'] ?? '',
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
        builder: (context, state) => const DashboardPage(),
      ),
    ],
  );
}

StatefulShellBranch _settingsBranch() {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: '/ajustes',
        builder: (context, state) => const SettingsOverviewPage(),
        routes: [
          GoRoute(
            path: 'cuenta',
            builder: (context, state) => const AccountPage(),
          ),
          GoRoute(
            path: 'idioma',
            builder: (context, state) => const LanguageSettingsPage(),
          ),
          GoRoute(
            path: 'tema',
            builder: (context, state) => const ThemeSettingsPage(),
          ),
          GoRoute(
            path: 'diagramas',
            builder: (context, state) => const DiagramSettingsPage(),
          ),
          GoRoute(
            path: 'editor',
            builder: (context, state) => const EditorSettingsPage(),
          ),
          GoRoute(
            path: 'contacto',
            builder: (context, state) => const ContactSupportPage(),
          ),
        ],
      ),
    ],
  );
}
