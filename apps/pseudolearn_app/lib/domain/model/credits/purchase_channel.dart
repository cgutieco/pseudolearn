enum PurchaseChannel {
  simulated('simulated', sells: true, sellsOwnTrial: true, restoresPurchases: false, managesSubscriptions: false, quotesPriceAtCheckout: false),
  appStore('app_store', sells: true, sellsOwnTrial: false, restoresPurchases: true, managesSubscriptions: true, quotesPriceAtCheckout: false),
  paddle('paddle', sells: true, sellsOwnTrial: false, restoresPurchases: false, managesSubscriptions: true, quotesPriceAtCheckout: true),
  unavailable('unavailable', sells: false, sellsOwnTrial: false, restoresPurchases: false, managesSubscriptions: false, quotesPriceAtCheckout: false);

  final String wireName;
  final bool sells;
  final bool sellsOwnTrial;
  final bool restoresPurchases;
  final bool managesSubscriptions;
  final bool quotesPriceAtCheckout;

  const PurchaseChannel(
    this.wireName, {
    required this.sells,
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
