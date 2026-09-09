enum StoreScene {
  syncedViews('01-synced-views'),
  stepByStep('02-step-by-step'),
  traceTable('03-trace-table'),
  equivalentCode('04-equivalent-code'),
  knowledgeBase('05-knowledge-base');

  final String fileSlug;

  const StoreScene(this.fileSlug);
}

const List<StoreScene> storyOrder = <StoreScene>[
  StoreScene.syncedViews,
  StoreScene.stepByStep,
  StoreScene.traceTable,
  StoreScene.equivalentCode,
  StoreScene.knowledgeBase,
];
