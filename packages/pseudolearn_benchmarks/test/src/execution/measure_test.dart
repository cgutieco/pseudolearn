import 'package:pseudolearn_benchmarks/pseudolearn_benchmarks.dart';
import 'package:test/test.dart';

void main() {
  test('rejects invalid analysis', () {
    expect(analyze('Proceso Invalid Definir FinProceso'), isNull);
  });
  test('runs empty program in both modes', () {
    final program = analyze('Proceso Empty\nFinProceso')!;
    expect(measureUnobserved(program, ''), isA<RunSample>());
    expect(measureObserved(program, ''), isA<RunSample>());
  });
  test('rejects wrong expected output', () {
    final program = analyze('Proceso Empty\nFinProceso')!;
    expect(measureObserved(program, 'wrong'), isA<RunFailure>());
  });
  test('rejects exhausted step budget', () {
    final program = analyze('Proceso Empty\nFinProceso')!;
    expect(measureObserved(program, '', maximumSteps: 0), isA<RunFailure>());
  });
  test('rejects unprovided input', () {
    final program = analyze(
      'Proceso Input\nDefinir number Como Entero\nLeer number\nFinProceso',
    )!;
    expect(measureUnobserved(program, ''), isA<RunFailure>());
  });
  test('returns an expected failure for runtime arithmetic faults', () {
    final program = analyze('Proceso Fault\nEscribir 1 div 0\nFinProceso')!;
    expect(measureUnobserved(program, ''), isA<RunFailure>());
    expect(measureObserved(program, ''), isA<RunFailure>());
  });
}
