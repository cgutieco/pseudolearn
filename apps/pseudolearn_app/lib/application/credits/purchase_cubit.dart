import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../domain/model/credits/agent_product.dart';
import '../../domain/model/credits/credits_outcome.dart';
import '../../domain/model/credits/legal_document.dart';
import '../../domain/model/credits/purchase_attempt.dart';
import '../../domain/ports/credits_gateway.dart';
import '../../domain/ports/external_url_launcher.dart';
import '../../domain/ports/pending_purchases.dart';
import '../../domain/ports/purchase_store.dart';
import 'credits_cubit.dart';
import 'purchase_state.dart';

final class PurchaseCubit extends Cubit<PurchaseState> {
  static const String returnScheme = 'pseudolearn';
  static const String returnHost = 'agent';
  static const String returnPath = '/purchase';

  final PurchaseStore _store;
  final PendingPurchases _pendingPurchases;
  final CreditsGateway _gateway;
  final CreditsCubit _credits;
  final ExternalUrlLauncher _links;
  late final StreamSubscription<PurchaseReceipt> _pending;
  late final StreamSubscription<Uri> _returns;

  PurchaseCubit({
    required PurchaseStore store,
    required PendingPurchases pending,
    required this._gateway,
    required this._credits,
    required this._links,
    Stream<Uri> returns = const Stream.empty(),
  }) : _store = store,
       _pendingPurchases = pending,
       super(PurchaseState(channel: store.channel)) {
    _pending = _pendingPurchases.pendingReceipts().listen(_redeemPending);
    _returns = returns.where(_isPurchaseReturn).listen((_) => _onReturn());
    unawaited(_loadPrices());
  }

  Future<void> buy(AgentProduct product) async {
    if (state.status == PurchaseStatus.purchasing) return;
    emit(state.withStatus(PurchaseStatus.purchasing, product: product));
    final attempt = await _store.purchase(product);
    if (isClosed) return;
    switch (attempt) {
      case PurchaseConfirmed(:final receipt):
        await _redeem(receipt, product);
      case PurchaseCancelled():
        emit(state.withStatus(PurchaseStatus.cancelled, product: product));
      case PurchaseContinuesOutside():
        emit(state.withStatus(PurchaseStatus.continuesOutside, product: product));
      case PurchaseRefused(:final failure):
        emit(state.withStatus(PurchaseStatus.failed, product: product, failure: failure));
    }
  }

  Future<void> restore() async {
    await _pendingPurchases.restore();
    await _credits.refresh();
  }

  Future<bool> manageSubscription() => _store.manageSubscription();

  Future<bool> openLegal(LegalDocument document, String languageCode) =>
      _links.launchExternalUrl(document.urlFor(languageCode));

  Future<void> _redeem(PurchaseReceipt receipt, AgentProduct product) async {
    final outcome = await _redeemAndFinish(receipt);
    if (isClosed) return;
    emit(switch (outcome) {
      CreditsKnown() => state.withStatus(PurchaseStatus.completed, product: product),
      CreditsUnavailable(:final failure) => state.withStatus(PurchaseStatus.failed, product: product, failure: failure),
    });
  }

  Future<void> _redeemPending(PurchaseReceipt receipt) async {
    await _redeemAndFinish(receipt);
  }

  Future<CreditsOutcome> _redeemAndFinish(PurchaseReceipt receipt) async {
    final outcome = await _gateway.redeem(receipt);
    if (outcome is CreditsKnown) {
      _credits.apply(outcome);
      await _pendingPurchases.finish(receipt);
    }
    return outcome;
  }

  Future<void> _loadPrices() async {
    final prices = await _store.prices();
    if (!isClosed) emit(state.withPrices(prices));
  }

  bool _isPurchaseReturn(Uri link) =>
      link.scheme == returnScheme && link.host == returnHost && link.path == returnPath;

  Future<void> _onReturn() async {
    if (!isClosed && state.status == PurchaseStatus.continuesOutside) {
      emit(state.withStatus(PurchaseStatus.idle));
    }
    await _credits.refresh();
  }

  @override
  Future<void> close() async {
    await _pending.cancel();
    await _returns.cancel();
    return super.close();
  }
}
