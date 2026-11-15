import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/credits/agent_product.dart';

void main() {
  test('every product is found by its store id', () {
    for (final product in AgentProduct.values) {
      expect(AgentProduct.fromStoreId(product.storeId), product);
    }
  });

  test('foreign or empty store ids are not products', () {
    expect(AgentProduct.fromStoreId(''), isNull);
    expect(AgentProduct.fromStoreId('com.other.product'), isNull);
  });
}
