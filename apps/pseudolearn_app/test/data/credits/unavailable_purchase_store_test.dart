import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/credits/unavailable_purchase_store.dart';
import 'package:pseudolearn_app/domain/model/credits/agent_product.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_failure.dart';
import 'package:pseudolearn_app/domain/model/credits/purchase_attempt.dart';
import 'package:pseudolearn_app/domain/model/credits/purchase_channel.dart';

void main() {
  const store = UnavailablePurchaseStore();

  test('every product is refused because purchases are disabled on this build', () async {
    for (final product in AgentProduct.values) {
      final attempt = await store.purchase(product);
      expect((attempt as PurchaseRefused).failure, CreditFailure.purchasesDisabled);
    }
  });

  test('it quotes no prices and manages no subscription', () async {
    expect(await store.prices(), isEmpty);
    expect(await store.manageSubscription(), isFalse);
    expect(store.channel, PurchaseChannel.unavailable);
    expect(store.channel.sells, isFalse);
  });
}
