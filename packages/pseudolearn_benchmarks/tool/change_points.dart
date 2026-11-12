import 'dart:math';

List<int> detectChangePoints(List<double> samples) {
  if (samples.length < 10) return const [];
  final candidates = <int>[];
  for (var boundary = 5; boundary <= samples.length - 5; boundary++) {
    final first = samples.take(boundary).toList();
    final last = samples.skip(boundary).toList();
    final difference = (average(first) - average(last)).abs();
    final uncertainty = sqrt(
      variance(first) / first.length + variance(last) / last.length,
    );
    final practical = max(average(first).abs(), average(last).abs()) * 0.05;
    if (difference > practical && difference > 3.3 * uncertainty) {
      candidates.add(boundary);
    }
  }
  return candidates;
}

double average(List<double> samples) =>
    samples.reduce((first, second) => first + second) / samples.length;

double variance(List<double> samples) {
  final center = average(samples);
  return samples
          .map((sample) => pow(sample - center, 2).toDouble())
          .reduce((first, second) => first + second) /
      (samples.length - 1);
}
