import 'package:bloc/bloc.dart';
import '../../domain/model/credits/agent_product.dart';
import '../../domain/model/credits/credits_outcome.dart';
import '../../domain/ports/credits_gateway.dart';
import '../../domain/ports/purchase_store.dart';
import 'credits_cubit.dart';
import 'purchase_state.dart';

final class PurchaseCubit extends Cubit<PurchaseState> {
  final PurchaseStore _store;
  final CreditsGateway _gateway;
  final CreditsCubit _credits;

  PurchaseCubit({
    required PurchaseStore store,
    required CreditsGateway gateway,
    required CreditsCubit credits,
  }) : _store = store,
       _gateway = gateway,
       _credits = credits,
       super(const PurchaseState());

  Future<void> buy(AgentProduct product) async {
    if (state.status == PurchaseStatus.purchasing) return;
    emit(PurchaseState(status: PurchaseStatus.purchasing, product: product));
    final receipt = await _store.purchase(product);
    if (receipt == null) {
      emit(PurchaseState(status: PurchaseStatus.cancelled, product: product));
      return;
    }
    final outcome = await _gateway.redeem(receipt);
    _credits.apply(outcome);
    if (isClosed) return;
    emit(switch (outcome) {
      CreditsKnown() => PurchaseState(status: PurchaseStatus.completed, product: product),
      CreditsUnavailable(:final failure) =>
        PurchaseState(status: PurchaseStatus.failed, product: product, failure: failure),
    });
  }
}
