import 'package:pseudolearn_benchmarks/pseudolearn_benchmarks.dart';
import 'package:test/test.dart';

void main() {
  for (final workload in [...annexWorkloads, ...awfyWorkloads]) {
    test(
      '${workload.name} validates independent expected output in both modes',
      () {
        final program = analyze(workload.source);
        expect(program, isNotNull);
        final unobserved = measureUnobserved(program!, workload.expectedOutput);
        final observed = measureObserved(program, workload.expectedOutput);
        expect(unobserved, isA<RunSample>());
        expect(observed, isA<RunSample>());
        expect((observed as RunSample).steps, (unobserved as RunSample).steps);
        expect(observed.events, greaterThan(0));
      },
    );
  }
}
