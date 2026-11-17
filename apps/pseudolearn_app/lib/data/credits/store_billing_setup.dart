import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'app_store_purchase_flow.dart';
import 'google_play_purchase_flow.dart';
import 'in_app_purchase_store_client.dart';
import 'store_billing_client.dart';
import 'store_billing_profile.dart';
import 'unfinished_store_transactions.dart';

typedef StoreBillingSetup = ({
  StoreBillingClient client,
  UnfinishedStoreTransactions unfinished,
  StoreBillingProfile profile,
});

StoreBillingSetup appStoreBillingSetup() {
  final purchases = InAppPurchase.instance;
  return (
    client: InAppPurchaseStoreClient(purchases: purchases, flow: AppStorePurchaseFlow(purchases)),
    unfinished: const StoreRedeliversUnfinishedTransactions(),
    profile: StoreBillingProfile.appStore,
  );
}

StoreBillingSetup googlePlayBillingSetup() {
  final purchases = InAppPurchase.instance;
  final flow = GooglePlayPurchaseFlow(
    purchases: purchases,
    billing: purchases.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>(),
  );
  return (
    client: InAppPurchaseStoreClient(purchases: purchases, flow: flow),
    unfinished: flow,
    profile: StoreBillingProfile.googlePlay,
  );
}
