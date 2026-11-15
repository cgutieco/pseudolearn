import '../../domain/model/credits/credit_failure.dart';
import '../../domain/model/credits/purchase_channel.dart';
import '../l10n/generated/app_localizations.dart';

String agentFailureText(AppLocalizations l10n, CreditFailure failure) => switch (failure) {
  CreditFailure.unauthenticated => l10n.agentFailureUnauthenticated,
  CreditFailure.subscriptionRequired => l10n.agentFailureSubscriptionRequired,
  CreditFailure.creditsExhausted => l10n.agentFailureCreditsExhausted,
  CreditFailure.requestCap => l10n.agentFailureRequestCap,
  CreditFailure.rateLimited => l10n.agentFailureRateLimited,
  CreditFailure.modelUnconfigured => l10n.agentFailureModelUnconfigured,
  CreditFailure.purchasesDisabled => l10n.agentFailurePurchasesDisabled,
  CreditFailure.trialUsed => l10n.agentFailureTrialUsed,
  CreditFailure.alreadySubscribed => l10n.agentFailureAlreadySubscribed,
  CreditFailure.purchaseOwnedElsewhere => l10n.agentFailurePurchaseOwnedElsewhere,
  CreditFailure.invalidPurchase => l10n.agentFailureInvalidPurchase,
  CreditFailure.purchaseNotApplied => l10n.agentFailurePurchaseNotApplied,
  CreditFailure.offline => l10n.agentFailureOffline,
  CreditFailure.upstream => l10n.agentFailureUpstream,
};

String agentStoreName(AppLocalizations l10n, PurchaseChannel channel) => switch (channel) {
  PurchaseChannel.simulated => l10n.agentStoreSimulated,
  PurchaseChannel.appStore => l10n.agentStoreAppStore,
  PurchaseChannel.paddle => l10n.agentStorePaddle,
  PurchaseChannel.unavailable => l10n.agentStoreUnavailable,
};

String agentStepText(AppLocalizations l10n, String key) => switch (key) {
  'agentStepReadScreen' => l10n.agentStepReadScreen,
  'agentStepSearch' => l10n.agentStepSearch,
  'agentStepListDocuments' => l10n.agentStepListDocuments,
  'agentStepReadDocument' => l10n.agentStepReadDocument,
  'agentStepCheck' => l10n.agentStepCheck,
  'agentStepRun' => l10n.agentStepRun,
  'agentStepTranslate' => l10n.agentStepTranslate,
  'agentStepFormat' => l10n.agentStepFormat,
  'agentStepProgress' => l10n.agentStepProgress,
  'agentStepLesson' => l10n.agentStepLesson,
  'agentStepExercise' => l10n.agentStepExercise,
  'agentStepExplain' => l10n.agentStepExplain,
  'agentStepCreateDocument' => l10n.agentStepCreateDocument,
  'agentStepRenameDocument' => l10n.agentStepRenameDocument,
  'agentStepEditDocument' => l10n.agentStepEditDocument,
  'agentStepReplaceDocument' => l10n.agentStepReplaceDocument,
  'agentStepDeleteDocument' => l10n.agentStepDeleteDocument,
  'agentStepArguments' => l10n.agentStepArguments,
  'agentStepCreateExercise' => l10n.agentStepCreateExercise,
  'agentStepUpdateExercise' => l10n.agentStepUpdateExercise,
  'agentStepDeleteExercise' => l10n.agentStepDeleteExercise,
  'agentStepHint' => l10n.agentStepHint,
  'agentStepRevealSolution' => l10n.agentStepRevealSolution,
  'agentStepNavigate' => l10n.agentStepNavigate,
  'agentStepTheme' => l10n.agentStepTheme,
  'agentStepLanguage' => l10n.agentStepLanguage,
  'agentStepProfile' => l10n.agentStepProfile,
  _ => l10n.agentStepUnknown,
};
