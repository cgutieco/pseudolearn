enum PurchaseChannel {
  simulated('simulated', sellsOwnTrial: true, restoresPurchases: false, managesSubscriptions: false, quotesPriceAtCheckout: false),
  appStore('app_store', sellsOwnTrial: false, restoresPurchases: true, managesSubscriptions: true, quotesPriceAtCheckout: false),
  paddle('paddle', sellsOwnTrial: false, restoresPurchases: false, managesSubscriptions: true, quotesPriceAtCheckout: true);

  final String wireName;
  final bool sellsOwnTrial;
  final bool restoresPurchases;
  final bool managesSubscriptions;
  final bool quotesPriceAtCheckout;

  const PurchaseChannel(
    this.wireName, {
    required this.sellsOwnTrial,
    required this.restoresPurchases,
    required this.managesSubscriptions,
    required this.quotesPriceAtCheckout,
  });

  static PurchaseChannel? fromWireName(String? name) {
    for (final channel in values) {
      if (channel.wireName == name) return channel;
    }
    return null;
  }
}
