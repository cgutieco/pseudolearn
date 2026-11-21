import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/credits/store_billing_profile.dart';
import 'package:pseudolearn_app/domain/model/credits/purchase_channel.dart';

void main() {
  test('the App Store keeps its channel, its subscriptions page and treats pending as in progress', () {
    final profile = StoreBillingProfile.appStore;
    expect(profile.channel, PurchaseChannel.appStore);
    expect(profile.subscriptionsPage.toString(), 'https://apps.apple.com/account/subscriptions');
    expect(profile.pendingMeansDeferredPayment, isFalse);
  });

  test('Google Play points at the plan in its subscriptions page and treats pending as a deferred payment', () {
    final profile = StoreBillingProfile.googlePlay;
    expect(profile.channel, PurchaseChannel.googlePlay);
    expect(profile.subscriptionsPage.host, 'play.google.com');
    expect(profile.subscriptionsPage.path, '/store/account/subscriptions');
    expect(profile.subscriptionsPage.queryParameters, {'sku': 'pseudolearn.nodo.monthly', 'package': 'com.pseudolearn.app'});
    expect(profile.pendingMeansDeferredPayment, isTrue);
  });
}
