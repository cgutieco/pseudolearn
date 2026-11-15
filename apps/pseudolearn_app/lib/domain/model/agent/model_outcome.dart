import '../credits/credit_balance.dart';
import '../credits/credit_failure.dart';
import 'model_item.dart';

sealed class ModelOutcome {
  const ModelOutcome();
}

final class ModelAnswered extends ModelOutcome {
  final List<ModelItem> items;
  final CreditBalance? balance;

  const ModelAnswered({required this.items, this.balance});
}

final class ModelFailed extends ModelOutcome {
  final CreditFailure failure;
  final bool retryable;

  const ModelFailed(this.failure, {this.retryable = false});
}
