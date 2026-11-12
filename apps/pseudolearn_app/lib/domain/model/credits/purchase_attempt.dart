import 'agent_product.dart';
import 'credit_failure.dart';

sealed class PurchaseAttempt {
  const PurchaseAttempt();
}

final class PurchaseConfirmed extends PurchaseAttempt {
  final PurchaseReceipt receipt;

  const PurchaseConfirmed(this.receipt);
}

final class PurchaseCancelled extends PurchaseAttempt {
  const PurchaseCancelled();
}

final class PurchaseContinuesOutside extends PurchaseAttempt {
  const PurchaseContinuesOutside();
}

final class PurchaseRefused extends PurchaseAttempt {
  final CreditFailure failure;

  const PurchaseRefused(this.failure);
}
