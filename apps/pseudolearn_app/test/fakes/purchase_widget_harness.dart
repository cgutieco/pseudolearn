import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/credits/credits_cubit.dart';
import 'package:pseudolearn_app/application/credits/purchase_cubit.dart';
import 'package:pseudolearn_app/domain/model/credits/credits_outcome.dart';
import 'package:pseudolearn_app/domain/ports/purchase_store.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import 'fake_agent_ports.dart';
import 'fake_purchase_ports.dart';

final class PurchaseWidgetHarness {
  final FakeCreditsGateway gateway;
  final FakePendingPurchases pending = FakePendingPurchases();
  final RecordingUrlLauncher links = RecordingUrlLauncher();
  final PurchaseStore store;
  late final CreditsCubit credits = CreditsCubit(gateway: gateway);
  late final PurchaseCubit purchases = PurchaseCubit(
    store: store,
    pending: pending,
    gateway: gateway,
    credits: credits,
    links: links,
  );

  PurchaseWidgetHarness({required this.store, CreditsOutcome? balance}) : gateway = FakeCreditsGateway(balance);

  Future<void> pump(WidgetTester tester, Widget child, {String locale = 'es', bool refresh = true}) async {
    if (refresh) await credits.refresh();
    addTearDown(credits.close);
    addTearDown(purchases.close);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      locale: Locale(locale),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, built) => DesignCanvas(child: built ?? const SizedBox.shrink()),
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [BlocProvider.value(value: credits), BlocProvider.value(value: purchases)],
          child: SingleChildScrollView(child: child),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }
}
