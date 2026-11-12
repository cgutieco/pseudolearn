import 'credit_failure.dart';

sealed class CheckoutLink {
  const CheckoutLink();
}

final class CheckoutLinkReady extends CheckoutLink {
  final Uri url;

  const CheckoutLinkReady(this.url);
}

final class CheckoutLinkRefused extends CheckoutLink {
  final CreditFailure failure;

  const CheckoutLinkRefused(this.failure);
}
