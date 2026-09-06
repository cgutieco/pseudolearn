// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PseudoLearn';

  @override
  String get navEditor => 'Editor';

  @override
  String get navFlowchart => 'Flowchart';

  @override
  String get navTrace => 'Trace table';

  @override
  String get navKnowledge => 'Knowledge base';

  @override
  String get navLibrary => 'My algorithms';

  @override
  String get navSettings => 'Settings';

  @override
  String get actionSave => 'Save';

  @override
  String get actionRun => 'Run';

  @override
  String get actionStep => 'Step';

  @override
  String get diagramZoomIn => 'Zoom in';

  @override
  String get diagramZoomOut => 'Zoom out';

  @override
  String get diagramFitToView => 'Fit the diagram to the view';

  @override
  String get actionStop => 'Stop';

  @override
  String get actionStepOverBlock => 'Step over block';

  @override
  String get actionStepOutOfBlock => 'Step out of block';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionStepInto => 'Step';

  @override
  String get actionExport => 'Export';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionRename => 'Rename';

  @override
  String get actionCreate => 'Create';

  @override
  String get actionCopy => 'Copy';

  @override
  String get languageSystem => 'System language';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageEnglish => 'English';

  @override
  String get profileSpanish => 'Classic Spanish';

  @override
  String get profileEnglish => 'English';

  @override
  String diagnosticsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count issues',
      one: '1 issue',
      zero: 'No issues',
    );
    return '$_temp0';
  }

  @override
  String get libraryTitle => 'My algorithms';

  @override
  String get librarySearchPlaceholder => 'Search algorithms...';

  @override
  String get libraryNewDocument => 'New algorithm';

  @override
  String get libraryEmptyTitle => 'No algorithms yet';

  @override
  String get libraryEmptyDescription =>
      'Create your first algorithm to start programming.';

  @override
  String get libraryEmptySearchTitle => 'No results';

  @override
  String libraryEmptySearchDescription(String query) {
    return 'No algorithms found for \"$query\".';
  }

  @override
  String get dialogNewDocTitle => 'New algorithm';

  @override
  String get dialogNewDocNameLabel => 'Algorithm name';

  @override
  String get dialogNewDocProfileLabel => 'Syntax profile';

  @override
  String get dialogRenameDocTitle => 'Rename algorithm';

  @override
  String get dialogDeleteDocTitle => 'Delete algorithm';

  @override
  String dialogDeleteDocMessage(String title) {
    return 'Are you sure you want to delete \"$title\"? This action cannot be undone.';
  }

  @override
  String get tabEditor => 'Editor';

  @override
  String get tabDiagrams => 'Diagrams';

  @override
  String get tabTrace => 'Trace table';

  @override
  String get tabExport => 'Export';

  @override
  String get exportComingSoon => 'Available when the export engine is ready';

  @override
  String get outputPanelTitle => 'Program output';

  @override
  String outputLinesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines',
      one: '1 line',
      zero: '0 lines',
    );
    return '$_temp0';
  }

  @override
  String get outputPreviousExecution => 'from previous execution';

  @override
  String get outputEmpty => 'Program output will appear here.';

  @override
  String stepCounter(int current, int max) {
    return 'Step $current of $max';
  }

  @override
  String get executionStatusIdle => 'Not running';

  @override
  String executionStatusPaused(int line) {
    return 'Paused on line $line';
  }

  @override
  String get executionStatusRunning => 'Running';

  @override
  String get executionStatusAwaitingInput => 'Waiting for input';

  @override
  String get executionStatusFinished => 'Execution finished';

  @override
  String get traceRowOpen => 'In progress';

  @override
  String statementCounter(int current) {
    return 'Statement $current';
  }

  @override
  String get trackingStripEmpty => 'No change in this step';

  @override
  String get trackingStripLabel => 'Changed';

  @override
  String get companionToggle => 'Companion';

  @override
  String get tabEquivalentCode => 'Equivalent code';

  @override
  String get bannerStepLimitTitle => 'Step limit reached';

  @override
  String get bannerStepLimitBody =>
      'The program reached the step limit without terminating. Check for potential infinite loops.';

  @override
  String get bannerSuccessTitle => 'Execution finished successfully';

  @override
  String get bannerErrorTitle => 'Execution halted';

  @override
  String get bannerDismiss => 'Dismiss notice';

  @override
  String get inputDialogTitle => 'Data input';

  @override
  String get inputDialogPrompt => 'Enter a value to continue:';

  @override
  String get inputDialogSubmit => 'Submit';

  @override
  String get diagnosticsEmpty => 'No issues detected';

  @override
  String get flowchartEmpty =>
      'The flowchart will be available when code is error-free.';

  @override
  String get structogramEmpty =>
      'The structogram will be available when code is error-free.';

  @override
  String get diagramNotationFlowchart => 'Flowchart';

  @override
  String get diagramNotationClassDiagram => 'Class diagram';

  @override
  String get classDiagramEmpty =>
      'The class diagram will be available when code is error-free.';

  @override
  String get classDiagramNoClasses => 'This document declares no classes.';

  @override
  String get diagramNotationStructogram => 'Structogram';

  @override
  String get traceEmpty => 'Start execution to view the trace table.';

  @override
  String get traceStepHeader => 'Step';

  @override
  String get traceLineHeader => 'Line';

  @override
  String get traceScopeHeader => 'Scope';

  @override
  String get knowledgeTitle => 'Knowledge Base';

  @override
  String get knowledgeSearchPlaceholder => 'Search knowledge base...';

  @override
  String get knowledgeSectionRoute => 'Route';

  @override
  String get knowledgeSectionSpecification => 'Specification';

  @override
  String get knowledgeSectionExercises => 'Exercises';

  @override
  String get knowledgeRouteTrackFoundations => 'Track A · Foundations';

  @override
  String get knowledgeRouteTrackImperative =>
      'Track B · Imperative and structured';

  @override
  String get knowledgeRouteTrackObjectOriented =>
      'Track C · Object orientation';

  @override
  String get knowledgeModuleVisited => 'Visited';

  @override
  String get knowledgeTypeModule => 'Module';

  @override
  String get knowledgeTypeSpecification => 'Specification';

  @override
  String get knowledgeTypePrediction => 'Prediction';

  @override
  String get knowledgeTypeIllustration => 'Illustration';

  @override
  String get knowledgeTypeExample => 'Example';

  @override
  String get knowledgeTypeExercise => 'Exercise';

  @override
  String get knowledgeTypeReference => 'Reference';

  @override
  String get knowledgeEmptyTitle => 'No content';

  @override
  String get knowledgeEmptyDescription =>
      'No content is available in the knowledge base.';

  @override
  String get knowledgeEmptySearchTitle => 'No results';

  @override
  String knowledgeEmptySearchDescription(String query) {
    return 'No items found matching \"$query\".';
  }

  @override
  String get knowledgeErrorTitle => 'Content Error';

  @override
  String get knowledgeErrorDescription =>
      'Could not load knowledge base content.';

  @override
  String get knowledgeActionRetry => 'Retry';

  @override
  String get knowledgeDetailOpenInNewDocument => 'Open in a new document';

  @override
  String get knowledgeDetailCopied => 'Copied';

  @override
  String get knowledgeDetailNotFoundTitle => 'Item not found';

  @override
  String get knowledgeDetailNotFoundDescription =>
      'The requested item does not exist in the knowledge base.';

  @override
  String get knowledgeDetailBack => 'Back to knowledge base';

  @override
  String get knowledgeDetailSections => 'Sections';

  @override
  String get knowledgeModulePartQuestion => 'Question';

  @override
  String get knowledgeModulePartMachineModel =>
      'What changes in your mental model of the machine';

  @override
  String get knowledgeModulePartDevelopment => 'Development';

  @override
  String get knowledgeModulePartPrediction => 'Predict and run';

  @override
  String get knowledgeModulePartCommonErrors => 'Common errors';

  @override
  String get knowledgeModulePartSpecification => 'In the specification';

  @override
  String get knowledgeModulePartExercises => 'Exercises';

  @override
  String get knowledgePredictionCheck => 'Run';

  @override
  String get knowledgePredictionRetry => 'Try again';

  @override
  String get knowledgePredictionMatch => 'Matches';

  @override
  String knowledgePredictionMismatch(String predicted, String actual) {
    return 'You expected $predicted, the machine has $actual';
  }

  @override
  String get knowledgePredictionEmptyHint => 'Write your prediction';

  @override
  String knowledgePredictionNotReached(int step) {
    return 'The program doesn\'t reach step $step';
  }

  @override
  String knowledgeSpecReturnToModule(String moduleTitle) {
    return 'Return to module $moduleTitle';
  }

  @override
  String get exerciseLevel1 => 'Level 1 · Reproduce';

  @override
  String get exerciseLevel2 => 'Level 2 · Compose';

  @override
  String get exerciseLevel3 => 'Level 3 · Design';

  @override
  String get exerciseLevelShort1 => 'Level 1';

  @override
  String get exerciseLevelShort2 => 'Level 2';

  @override
  String get exerciseLevelShort3 => 'Level 3';

  @override
  String get exerciseKindPredict => 'Predict';

  @override
  String get exerciseKindComplete => 'Complete';

  @override
  String get exerciseKindModify => 'Modify';

  @override
  String get exerciseKindCreate => 'Create';

  @override
  String get exerciseCompletedBadge => 'Completed';

  @override
  String get exerciseFilterLevel => 'Level';

  @override
  String get exerciseFilterModule => 'Module';

  @override
  String get exerciseFilterConstruct => 'Construct';

  @override
  String get exerciseFilterAllLevels => 'All levels';

  @override
  String get exerciseFilterAllConstructs => 'All constructs';

  @override
  String get exerciseConstructConditional => 'Conditional';

  @override
  String get exerciseConstructMultipleSelection => 'Multiple selection';

  @override
  String get exerciseConstructConditionalLoop => 'Conditional loop';

  @override
  String get exerciseConstructPostConditionalLoop => 'Post-conditional loop';

  @override
  String get exerciseConstructCountedLoop => 'Counted loop';

  @override
  String get exerciseConstructArrayDeclaration => 'Arrays';

  @override
  String get exerciseConstructSubprogram => 'Subprograms';

  @override
  String get exerciseConstructClassDeclaration => 'Classes';

  @override
  String get exerciseClearFilters => 'Clear filters';

  @override
  String get exerciseBankEmptyTitle => 'No exercises';

  @override
  String get exerciseBankEmptyDescription =>
      'There are no exercises available in the knowledge base.';

  @override
  String get exerciseBankEmptyFilterTitle => 'No matching exercises';

  @override
  String get exerciseBankEmptyFilterDescription =>
      'No exercises match the selected filters or search query.';

  @override
  String exerciseStripTitle(String title) {
    return 'Exercise: $title';
  }

  @override
  String get exerciseStripCollapse => 'Collapse exercise strip';

  @override
  String get exerciseStripExpand => 'Expand exercise strip';

  @override
  String get exerciseActionCheck => 'Check';

  @override
  String get exerciseChecking => 'Checking...';

  @override
  String exercisePassedCount(int passed, int total) {
    return 'Meets $passed of $total cases';
  }

  @override
  String get exerciseAllCasesPassed => 'Meets all test cases!';

  @override
  String get exerciseHiddenFailureTitle => 'First failed hidden case:';

  @override
  String exerciseHiddenInputs(String inputs) {
    return 'Input: $inputs';
  }

  @override
  String exerciseHiddenExpected(String expected) {
    return 'Expected: $expected';
  }

  @override
  String exerciseHiddenActual(String actual) {
    return 'Actual: $actual';
  }

  @override
  String get exerciseOutcomeParseError =>
      'Program contains syntax errors and cannot be checked.';

  @override
  String get exerciseOutcomeHalted => 'Execution halted unexpectedly.';

  @override
  String get exerciseOutcomeStepLimit =>
      'Step limit reached (possible infinite loop).';

  @override
  String get exerciseOutcomeInputExhausted =>
      'Program requested more inputs than provided.';

  @override
  String get exerciseNotFoundTitle => 'Exercise not available';

  @override
  String exerciseNotFoundInCatalog(String id) {
    return 'The linked exercise ($id) does not exist in the catalog. You can edit and run this document normally.';
  }

  @override
  String get exerciseVisibleCasesTitle => 'Visible test cases:';

  @override
  String exerciseCaseInputsLabel(String inputs) {
    return 'Input: $inputs';
  }

  @override
  String exerciseCaseOutputsLabel(String outputs) {
    return 'Expected output: $outputs';
  }

  @override
  String exerciseUnmetAssertion(String requirement) {
    return 'Missing requirement: $requirement';
  }

  @override
  String onboardingStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingWelcomeTitle => 'Welcome to PseudoLearn';

  @override
  String get onboardingWelcomeSubtitle =>
      'Write pseudocode and watch it run: diagrams, trace table, and output, all at once.';

  @override
  String get onboardingWelcomeHighlightEngine =>
      'An engine that really runs, one instruction at a time';

  @override
  String get onboardingWelcomeHighlightDiagrams =>
      'Flowchart, structogram, and class diagram of the same program';

  @override
  String get onboardingWelcomeHighlightRoute =>
      'A learning route with exercises that check themselves';

  @override
  String get onboardingLabTitle => 'The live lab';

  @override
  String get onboardingLabSubtitle =>
      'Tap Step by step and watch the code, the diagrams, the trace table, and the output all react together.';

  @override
  String get onboardingLabBriefTitle => 'The case';

  @override
  String get onboardingLabBriefStatement =>
      'A thermometer starts at 30 degrees and cools three at a time until it reaches the 24-degree comfort point. Count how many times it cooled and announce the result.';

  @override
  String get onboardingLabReadOnly =>
      'Read-only view: here you watch, you do not edit.';

  @override
  String get onboardingLabSurfaceDiagrams => 'Diagrams';

  @override
  String get onboardingLabSurfaceTrace => 'Trace table';

  @override
  String get onboardingLabSurfaceOutput => 'Output';

  @override
  String get onboardingLabActionRestart => 'Restart';

  @override
  String get onboardingLabStatusReady => 'Ready to run the first instruction.';

  @override
  String onboardingLabStatusStepping(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count instructions executed',
      one: '1 instruction executed',
    );
    return '$_temp0';
  }

  @override
  String get onboardingLabStatusFinished =>
      'Program finished. Restart to watch it again.';

  @override
  String get onboardingLabUnavailable =>
      'The demo is not available right now. You can continue without it.';

  @override
  String get onboardingKnowledgeTitle => 'Your knowledge base';

  @override
  String get onboardingKnowledgeSubtitle =>
      'You are not alone in front of a blank page: a route, a specification, and an exercise bank are waiting for you.';

  @override
  String get onboardingKnowledgeRouteTitle => 'Personalised route';

  @override
  String get onboardingKnowledgeRouteDescription =>
      'Three chained tracks that lead from the foundations to object-oriented programming with pseudocode.';

  @override
  String get onboardingKnowledgeTrackFoundations => 'Foundations';

  @override
  String get onboardingKnowledgeTrackImperative => 'Imperative programming';

  @override
  String get onboardingKnowledgeTrackObjectOriented =>
      'Objects with pseudocode';

  @override
  String onboardingKnowledgeModuleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modules',
      one: '1 module',
    );
    return '$_temp0';
  }

  @override
  String get onboardingKnowledgeSpecificationTitle => 'Syntax specification';

  @override
  String get onboardingKnowledgeSpecificationDescription =>
      'Every construct of the language, with its exact shape and its runnable examples.';

  @override
  String onboardingKnowledgeSpecificationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sections',
      one: '1 section',
    );
    return '$_temp0';
  }

  @override
  String get onboardingKnowledgeExercisesTitle => 'Exercise bank';

  @override
  String get onboardingKnowledgeExercisesDescription =>
      'Statements with test cases the app checks for you, sorted by difficulty.';

  @override
  String onboardingKnowledgeExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '1 exercise',
    );
    return '$_temp0';
  }

  @override
  String onboardingKnowledgeLevelCount(int level, int count) {
    return 'Level $level: $count';
  }

  @override
  String get onboardingKnowledgeUnavailable =>
      'The catalogue could not be read right now. It will be available inside the app.';

  @override
  String get onboardingCompletionTitle => 'All set to get started';

  @override
  String get onboardingCompletionSubtitle =>
      'Create your first algorithm from scratch, or enter through the learning route if you would rather be guided.';

  @override
  String get onboardingActionCreateFirst => 'Create my first document';

  @override
  String get onboardingActionExploreRoute => 'Enter the learning route';

  @override
  String get onboardingActionNext => 'Next';

  @override
  String get onboardingActionBack => 'Back';

  @override
  String get onboardingActionSkip => 'Skip';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsSectionInformation => 'Information';

  @override
  String get settingsLanguage => 'Interface language';

  @override
  String get settingsLanguageNotice =>
      'Does not change the vocabulary of your documents';

  @override
  String get settingsTheme => 'Visual theme';

  @override
  String get settingsThemeSystem => 'System theme';

  @override
  String get settingsThemeLight => 'Light theme';

  @override
  String get settingsThemeDark => 'Dark theme';

  @override
  String get settingsRestartOnboarding => 'View introduction again';

  @override
  String get settingsContact => 'Contact & support';

  @override
  String settingsVersion(String version) {
    return 'v$version';
  }

  @override
  String get settingsBack => 'Back to settings';

  @override
  String get settingsAbout => 'About this setting';

  @override
  String get settingsLanguageOptions => 'Available languages';

  @override
  String get settingsThemeOptions => 'Available themes';

  @override
  String get settingsThemeNotice =>
      '“System theme” follows the light or dark appearance of your device';

  @override
  String get settingsDiagramAssist => 'Assisted zoom in diagrams';

  @override
  String get settingsDiagramAssistOptions =>
      'Behaviour while stepping through a program';

  @override
  String get settingsDiagramAssistOn => 'Follow the active step';

  @override
  String get settingsDiagramAssistOff => 'Keep the diagram still';

  @override
  String get settingsDiagramAssistNotice =>
      'While following is on, the diagram zooms into the running block and glides to the next one instead of jumping';

  @override
  String get settingsContactTitle => 'Contact & support';

  @override
  String get settingsContactEmpty => 'No contact information available.';

  @override
  String get settingsContactTipsTitle => 'Tips for reporting issues';

  @override
  String get settingsContactTipsBody =>
      'When contacting us about a technical issue, please describe the steps to reproduce and include the affected pseudocode snippet to help us assist you faster.';

  @override
  String get targetLanguagePython => 'Python';

  @override
  String get targetLanguageRust => 'Rust';

  @override
  String get exportAnalysisErrorTitle => 'Program with errors';

  @override
  String get exportAnalysisErrorDescription =>
      'Fix errors in the editor to view exported code.';

  @override
  String get exportCopyTooltip => 'Copy code';

  @override
  String get exportCopiedTooltip => 'Copied!';

  @override
  String get exportEmptySourceDescription =>
      'Write or open an algorithm to see its translation.';

  @override
  String get exportNotesTitle => 'Export notes';

  @override
  String get libraryDocumentOptions => 'Document options';

  @override
  String get severityError => 'ERROR';

  @override
  String get severityWarning => 'WARNING';

  @override
  String get severityInfo => 'INFO';

  @override
  String get severityHint => 'HINT';

  @override
  String get severitySuccess => 'SUCCESS';

  @override
  String get validationNameEmpty => 'The name cannot be empty';

  @override
  String get validationNameDuplicate =>
      'A document with this name already exists';

  @override
  String get executionRuntimeError => 'Runtime error';

  @override
  String get illustrationMemoryBoxesSemanticLabel =>
      'Illustration: three memory boxes, each with its name above and its value inside.';

  @override
  String get illustrationMemoryBoxesVariable1 => 'counter';

  @override
  String get illustrationMemoryBoxesValue1 => '3';

  @override
  String get illustrationMemoryBoxesVariable2 => 'total';

  @override
  String get illustrationMemoryBoxesValue2 => '12.5';

  @override
  String get illustrationMemoryBoxesVariable3 => 'active';

  @override
  String get illustrationMemoryBoxesValue3 => 'true';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsAccountNotLinked => 'Not linked';

  @override
  String get settingsAccountLinked => 'Linked';

  @override
  String get settingsAccountSyncNotice =>
      'Sign in to synchronize your algorithms and progress across devices.';

  @override
  String get settingsAccountOfflineNote =>
      'PseudoLearn works completely without an account. Your algorithms and progress are saved on this device.';

  @override
  String get settingsAccountSectionOptions => 'Sign-in options';

  @override
  String get settingsAccountSectionSession => 'Active session';

  @override
  String get settingsAccountPrivateRelay => 'Apple private email';

  @override
  String get authSignInWithApple => 'Continue with Apple';

  @override
  String get authSignInWithGoogle => 'Continue with Google';

  @override
  String get authSignInWithEmail => 'Continue with email';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get authSignOutAndDelete =>
      'Sign out and delete data from this device';

  @override
  String get authDeleteDataDialogTitle => 'Sign out and delete data?';

  @override
  String get authDeleteDataDialogMessage =>
      'All saved documents on this device will be deleted. This action cannot be undone.';

  @override
  String get authDeleteDataConfirm => 'Delete data and exit';

  @override
  String get authDeleteAccount => 'Delete account';

  @override
  String get authDeleteAccountDialogTitle => 'Delete account?';

  @override
  String get authDeleteAccountDialogMessage =>
      'Your account and all associated data will be permanently deleted from our servers. Local documents on this device will also be removed. This action cannot be undone.';

  @override
  String get authDeleteAccountConfirm => 'Delete account';

  @override
  String get authMagicLinkDialogTitle => 'Sign in with magic link';

  @override
  String get authMagicLinkEmailLabel => 'Email address';

  @override
  String get authMagicLinkSend => 'Send link';

  @override
  String authMagicLinkSentNotice(String email) {
    return 'We have sent a sign-in link to $email. Open it on this device to sign in.';
  }

  @override
  String get authAuthenticating => 'Signing in...';

  @override
  String get authErrorGeneric => 'Could not sign in. Please try again.';

  @override
  String get authErrorNoConnection =>
      'No internet connection. Please check your network.';

  @override
  String get syncBannerInProgress => 'Syncing library...';

  @override
  String get syncBannerConflictTitle => 'Conflicts detected';

  @override
  String syncBannerConflictMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conflict copies were created.',
      one: '1 conflict copy was created.',
    );
    return '$_temp0';
  }

  @override
  String get syncBannerErrorTitle => 'Sync error';

  @override
  String get syncBannerErrorMessage => 'Could not sync some changes.';

  @override
  String get syncRetryButton => 'Retry';

  @override
  String get syncStatusSynced => 'Synced';

  @override
  String get syncStatusPending => 'Pending upload';

  @override
  String get syncStatusLocalOnly => 'On this device only';

  @override
  String get syncConflictBadge => 'Conflict copy';

  @override
  String get navProgress => 'Progress';

  @override
  String get dashboardTitle => 'My progress';

  @override
  String get dashboardEmptyTitle => 'Nothing to summarise yet';

  @override
  String get dashboardEmptyMessage =>
      'Write your first algorithm or open a module of the learning route and your progress will show up here.';

  @override
  String get dashboardErrorTitle => 'The dashboard could not be built';

  @override
  String get dashboardLibraryTitle => 'Library';

  @override
  String get dashboardLibraryTotal => 'Algorithms created';

  @override
  String get dashboardLibraryProfileClassic => 'Spanish profile';

  @override
  String get dashboardLibraryProfileEnglish => 'English profile';

  @override
  String get dashboardRouteTitle => 'Learning route';

  @override
  String get dashboardRouteSubtitle => 'Modules visited per track';

  @override
  String get dashboardExercisesTitle => 'Exercises';

  @override
  String get dashboardExercisesByTrack => 'By track';

  @override
  String get dashboardExercisesByLevel => 'By level';

  @override
  String get dashboardExercisesByKind => 'By kind';

  @override
  String get dashboardNextStepTitle => 'Next step';

  @override
  String get dashboardNextStepDone =>
      'You have visited all fifteen modules of the route.';

  @override
  String get dashboardNextStepOpen => 'Open module';

  @override
  String get dashboardSyncTitle => 'Synchronisation';

  @override
  String get dashboardSyncLastAt => 'Last synchronisation';

  @override
  String get dashboardSyncNever => 'Not synchronised yet';

  @override
  String get dashboardSyncPending => 'Queued changes';

  @override
  String get dashboardSyncOldest => 'Age of the oldest one';

  @override
  String get dashboardSyncConflicts => 'Open conflicts';

  @override
  String dashboardSyncDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
      zero: 'Today',
    );
    return '$_temp0';
  }

  @override
  String get dashboardConceptsTitle => 'Concepts practised';

  @override
  String get dashboardConceptsSubtitle =>
      'Constructs you have already written in your own algorithms';

  @override
  String dashboardConceptDocuments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count algorithms',
      one: 'In 1 algorithm',
      zero: 'Unused',
    );
    return '$_temp0';
  }

  @override
  String get dashboardConceptConditional => 'Conditional';

  @override
  String get dashboardConceptMultipleSelection => 'Multiple selection';

  @override
  String get dashboardConceptConditionalLoop => 'Conditional loop';

  @override
  String get dashboardConceptPostConditionalLoop => 'Post-tested loop';

  @override
  String get dashboardConceptCountedLoop => 'Counted loop';

  @override
  String get dashboardConceptArray => 'Array';

  @override
  String get dashboardConceptSubprogram => 'Subprogram';

  @override
  String get dashboardConceptClass => 'Class';

  @override
  String get dashboardSpecificationTitle => 'Specification coverage';

  @override
  String get dashboardSpecificationSubtitle =>
      'Normative sections your algorithms already exercise';

  @override
  String get dashboardSpecificationExercised => 'Exercised';

  @override
  String get dashboardSpecificationPending => 'Not exercised';

  @override
  String get dashboardActivityTitle => 'Activity timeline';

  @override
  String get dashboardActivitySubtitle => 'Modules and exercises per week';

  @override
  String get dashboardCreationsTitle => 'Algorithms created over time';

  @override
  String get dashboardCreationsSubtitle => 'New algorithms per week';

  @override
  String dashboardWeekOf(int day, int month) {
    return 'Week of $day/$month';
  }

  @override
  String dashboardCoverageRatio(int done, int total) {
    return '$done of $total';
  }

  @override
  String get editorKeyIndent => 'Insert indentation';

  @override
  String get editorKeyDedent => 'Remove indentation';

  @override
  String get editorKeyAssignment => 'Insert assignment';

  @override
  String get editorKeyQuote => 'Insert quotation marks';

  @override
  String get editorKeyOpenParenthesis => 'Insert opening parenthesis';

  @override
  String get editorKeyCloseParenthesis => 'Insert closing parenthesis';

  @override
  String get editorKeyGreaterOrEqual => 'Insert greater than or equal';

  @override
  String get editorKeyLessOrEqual => 'Insert less than or equal';

  @override
  String get editorKeyTemplatesShow => 'Show structure templates';

  @override
  String get editorKeyTemplatesHide => 'Hide structure templates';

  @override
  String get editorActionHideKeyboard => 'Hide keyboard';

  @override
  String get actionExpand => 'Expand';

  @override
  String get actionCollapse => 'Collapse';
}
