import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/agent/file_agent_consent_store.dart';
import 'package:pseudolearn_app/data/agent/json_http_client.dart';
import 'package:pseudolearn_app/data/credits/proxy_credits_gateway.dart';
import 'package:pseudolearn_app/data/credits/unconfigured_credits_gateway.dart';
import 'package:pseudolearn_app/data/index/index_schema.dart';
import 'package:pseudolearn_app/data/progress/sqlite_assisted_progress_store.dart';
import 'package:pseudolearn_app/domain/model/credits/agent_product.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_failure.dart';
import 'package:pseudolearn_app/domain/model/credits/credits_outcome.dart';
import 'package:pseudolearn_app/domain/ports/access_token_source.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final class _Tokens implements AccessTokenSource {
  final String? token;

  const _Tokens(this.token);

  @override
  Future<String?> accessToken() async => token;
}

void main() {
  setUpAll(sqfliteFfiInit);

  test('consent is stored on disk, withdrawn and tolerant of tampering', () async {
    final directory = Directory.systemTemp.createTempSync('consent_');
    final store = FileAgentConsentStore(directory);
    expect(await store.hasConsented(), isFalse);
    await store.grant();
    expect(await FileAgentConsentStore(directory).hasConsented(), isTrue);
    File('${directory.path}/${FileAgentConsentStore.fileName}').writeAsStringSync('{"consent":"maybe"}');
    expect(await store.hasConsented(), isFalse);
    await store.withdraw();
    await store.withdraw();
    expect(await store.hasConsented(), isFalse);
    directory.deleteSync(recursive: true);
  });

  test('assisted progress is recorded once and keeps other progress fields', () async {
    final database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await IndexSchema.createAllTables(database);
    await database.insert(IndexSchema.progressTableName, {
      IndexSchema.columnContentId: 'ruta.ejercicio:a',
      IndexSchema.columnCompleted: 1,
    });
    final store = SqliteAssistedProgressStore(database);
    expect(await store.assistedIds(), isEmpty);
    await store.markAssisted('ruta.ejercicio:a');
    await store.markAssisted('ruta.ejercicio:a');
    await store.markAssisted('usuario.ejercicio:b');
    expect(await store.assistedIds(), {'ruta.ejercicio:a', 'usuario.ejercicio:b'});
    final row = (await database.query(IndexSchema.progressTableName, where: 'content_id = ?', whereArgs: ['ruta.ejercicio:a'])).single;
    expect(row[IndexSchema.columnCompleted], 1);
    expect(row[IndexSchema.columnDirty], 1);
    await database.close();
  });

  test('the credits proxy reads headers, posts purchases and maps failures', () async {
    final requests = <String>[];
    final gateway = ProxyCreditsGateway(
      functionsUrl: 'https://p/functions/v1',
      tokens: const _Tokens('jwt'),
      send: (method, uri, {headers = const {}, body}) async {
        requests.add('$method $uri');
        return const JsonHttpReply(
          status: 200,
          body: {'period_active': true, 'trial_used': true},
          headers: {'x-pseudolearn-credits-remaining': '290', 'x-pseudolearn-credits-allowance': '300'},
        );
      },
    );
    final balance = await gateway.balance() as CreditsKnown;
    expect(balance.balance.remaining, 290);
    expect(balance.trialUsed, isTrue);
    await gateway.redeem(const PurchaseReceipt(product: AgentProduct.topUp, store: 'simulated', transactionId: 't'));
    expect(requests, ['GET https://p/functions/v1/agent-credits', 'POST https://p/functions/v1/agent-credits/purchases']);
    final signedOut = ProxyCreditsGateway(functionsUrl: 'https://p', tokens: const _Tokens(null));
    expect((await signedOut.balance() as CreditsUnavailable).failure, CreditFailure.unauthenticated);
    final refused = ProxyCreditsGateway(
      functionsUrl: 'https://p',
      tokens: const _Tokens('jwt'),
      send: (method, uri, {headers = const {}, body}) async => const JsonHttpReply(
        status: 403,
        body: {'error': {'code': 'purchases_disabled'}},
        headers: {},
      ),
    );
    expect((await refused.balance() as CreditsUnavailable).failure, CreditFailure.purchasesDisabled);
    expect((await const UnconfiguredCreditsGateway().balance() as CreditsUnavailable).failure, CreditFailure.modelUnconfigured);
  });
}
