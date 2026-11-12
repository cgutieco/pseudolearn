import 'dart:io';

Future<Map<String, num>?> sampleProcess(int identifier) async {
  try {
    if (Platform.isWindows) return await _windows(identifier);
    final result = await Process.run('ps', [
      '-o',
      'rss=',
      '-o',
      'time=',
      '-p',
      '$identifier',
    ]);
    if (result.exitCode != 0) return null;
    final fields = (result.stdout as String).trim().split(RegExp(r'\s+'));
    if (fields.length != 2) return null;
    final clock = fields[1].split(':').map(double.parse).toList();
    final seconds = clock.reversed.indexed.fold<double>(
      0,
      (total, entry) => total + entry.$2 * _secondsFactor(entry.$1),
    );
    return {'rssBytes': int.parse(fields.first) * 1024, 'cpuSeconds': seconds};
  } on Object {
    return null;
  }
}

int _secondsFactor(int index) => switch (index) {
  0 => 1,
  1 => 60,
  _ => 3600,
};

Future<Map<String, num>?> _windows(int identifier) async {
  final result = await Process.run('powershell', [
    '-NoProfile',
    '-Command',
    '\$measured = Get-Process -Id $identifier -ErrorAction Stop; '
        'Write-Output (\$measured.WorkingSet64.ToString() + " " + '
        '\$measured.TotalProcessorTime.TotalSeconds.ToString([Globalization.CultureInfo]::InvariantCulture))',
  ]);
  if (result.exitCode != 0) return null;
  final fields = (result.stdout as String).trim().split(RegExp(r'\s+'));
  if (fields.length != 2) return null;
  return {
    'rssBytes': int.parse(fields.first),
    'cpuSeconds': double.parse(fields.last),
  };
}
