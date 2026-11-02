import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/simulated_scenario.dart';
import 'package:pseudolearn_app/engine/rust/rust_simulated_files.dart';
import 'package:pseudolearn_app/engine/rust/rust_simulated_http.dart';

Map<String, Object?> _capability(int slot) => {
  'slot': slot,
  'generation': 1,
  'rights': 4,
  'kind': 7,
};

SimulatedHostRequest _request(String url) => SimulatedHostRequest({
  'operation': 'network_send',
  'receiver': _capability(0),
  'arguments': [
    {
      'kind': 'http_request',
      'value': {'method': 'GET', 'url': url},
    },
  ],
});

void main() {
  group('RustSimulatedHttp', () {
    test('returns the response prepared for the granted origin', () {
      final files = RustSimulatedFiles(const {});
      files.register(_capability(0), '', 0);
      final http = RustSimulatedHttp(
        SimulatedScenario.preparedHttp.capabilities,
        files,
      );

      final reply = http.reply(_request('https://example.test/greeting'));
      final value = (reply['value'] as Map<String, Object?>)['value'];

      expect(reply['outcome'], 'committed');
      expect((value as Map<String, Object?>)['body'], [104, 111, 108, 97]);
      expect(http.hostFields['network_origins'], ['https://example.test']);
    });

    test('rejects an origin without a prepared grant', () {
      final files = RustSimulatedFiles(const {});
      files.register(_capability(0), '', 0);
      final http = RustSimulatedHttp(
        SimulatedScenario.preparedHttp.capabilities,
        files,
      );

      expect(
        () => http.reply(_request('https://other.test/greeting')),
        throwsA(
          isA<RustSimulatedHostFailure>().having(
            (failure) => failure.code,
            'code',
            'destino_denegado',
          ),
        ),
      );
    });
  });
}
