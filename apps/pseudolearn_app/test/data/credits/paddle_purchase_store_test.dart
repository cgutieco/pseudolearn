import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/credits/paddle_purchase_store.dart';
import 'package:pseudolearn_app/domain/model/credits/agent_product.dart';
import 'package:pseudolearn_app/domain/model/credits/checkout_link.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_failure.dart';
import 'package:pseudolearn_app/domain/model/credits/purchase_attempt.dart';
import 'package:pseudolearn_app/domain/model/credits/purchase_channel.dart';
import '../../fakes/fake_purchase_ports.dart';

final _checkoutUrl = Uri.parse('https://pseudolearn.app/checkout?_ptxn=txn_1');

void main() {
  test('a purchase opens the checkout in the browser and continues outside the app', () async {
    final checkouts = FakeCheckoutGateway(checkoutLink: CheckoutLinkReady(_checkoutUrl));
    final launcher = RecordingUrlLauncher();
    final store = PaddlePurchaseStore(checkouts: checkouts, launcher: launcher);
    expect(await store.purchase(AgentProduct.topUp), isA<PurchaseContinuesOutside>());
    expect(checkouts.requested, [AgentProduct.topUp]);
    expect(launcher.opened, [_checkoutUrl]);
    expect(store.channel, PurchaseChannel.paddle);
  });

  test('a refused checkout keeps the server reason', () async {
    final checkouts = FakeCheckoutGateway(checkoutLink: const CheckoutLinkRefused(CreditFailure.alreadySubscribed));
    final store = PaddlePurchaseStore(checkouts: checkouts, launcher: RecordingUrlLauncher());
    expect((await store.purchase(AgentProduct.monthly) as PurchaseRefused).failure, CreditFailure.alreadySubscribed);
  });

  test('a browser that does not open is a failed purchase', () async {
    final checkouts = FakeCheckoutGateway(checkoutLink: CheckoutLinkReady(_checkoutUrl));
    final store = PaddlePurchaseStore(checkouts: checkouts, launcher: RecordingUrlLauncher(result: false));
    expect((await store.purchase(AgentProduct.monthly) as PurchaseRefused).failure, CreditFailure.upstream);
  });

  test('the portal opens when Paddle knows the customer and fails quietly otherwise', () async {
    final portal = Uri.parse('https://customer-portal.paddle.com/x');
    final launcher = RecordingUrlLauncher();
    final known = PaddlePurchaseStore(checkouts: FakeCheckoutGateway(portalLink: CheckoutLinkReady(portal)), launcher: launcher);
    expect(await known.manageSubscription(), isTrue);
    expect(launcher.opened, [portal]);
    final unknown = PaddlePurchaseStore(checkouts: FakeCheckoutGateway(), launcher: launcher);
    expect(await unknown.manageSubscription(), isFalse);
    expect(await unknown.prices(), isEmpty);
  });
}
