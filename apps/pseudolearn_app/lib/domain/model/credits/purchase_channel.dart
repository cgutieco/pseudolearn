enum PurchaseChannel {
  simulated('simulated', sellsOwnTrial: true, restoresPurchases: false, managesSubscriptions: false),
  appStore('app_store', sellsOwnTrial: false, restoresPurchases: true, managesSubscriptions: true),
  paddle('paddle', sellsOwnTrial: false, restoresPurchases: false, managesSubscriptions: true);

  final String wireName;
  final bool sellsOwnTrial;
  final bool restoresPurchases;
  final bool managesSubscriptions;

  const PurchaseChannel(
    this.wireName, {
    required this.sellsOwnTrial,
    required this.restoresPurchases,
    required this.managesSubscriptions,
  });

  static PurchaseChannel? fromWireName(String? name) {
    for (final channel in values) {
      if (channel.wireName == name) return channel;
    }
    return null;
  }
}
