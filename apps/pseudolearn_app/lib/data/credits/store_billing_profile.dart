import '../../domain/model/credits/agent_product.dart';
import '../../domain/model/credits/purchase_channel.dart';

final class StoreBillingProfile {
  static const String androidApplicationId = 'com.pseudolearn.app';

  static final StoreBillingProfile appStore = StoreBillingProfile(
    channel: PurchaseChannel.appStore,
    subscriptionsPage: Uri.parse('https://apps.apple.com/account/subscriptions'),
    pendingMeansDeferredPayment: false,
  );

  static final StoreBillingProfile googlePlay = StoreBillingProfile(
    channel: PurchaseChannel.googlePlay,
    subscriptionsPage: Uri.https('play.google.com', '/store/account/subscriptions', {
      'sku': AgentProduct.monthly.storeId,
      'package': androidApplicationId,
    }),
    pendingMeansDeferredPayment: true,
  );

  final PurchaseChannel channel;
  final Uri subscriptionsPage;
  final bool pendingMeansDeferredPayment;

  const StoreBillingProfile({
    required this.channel,
    required this.subscriptionsPage,
    required this.pendingMeansDeferredPayment,
  });
}
