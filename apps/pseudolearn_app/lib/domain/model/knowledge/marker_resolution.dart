import '../analysis/app_diagnostic.dart';
import 'list_equality.dart';

sealed class MarkerResolution {
  const MarkerResolution();
}

final class ResolvedMarkerText extends MarkerResolution {
  final String text;

  const ResolvedMarkerText(this.text);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResolvedMarkerText &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;
}

final class ResolvedMarkerTable extends MarkerResolution {
  final List<String> headers;
  final List<List<String>> rows;

  const ResolvedMarkerTable({
    required this.headers,
    required this.rows,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResolvedMarkerTable &&
          runtimeType == other.runtimeType &&
          listEquals(headers, other.headers) &&
          _rowsEqual(rows, other.rows);

  @override
  int get hashCode => Object.hash(
        Object.hashAll(headers),
        Object.hashAll(rows.map(Object.hashAll)),
      );

  static bool _rowsEqual(List<List<String>> a, List<List<String>> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!listEquals(a[i], b[i])) return false;
    }
    return true;
  }
}

final class ResolvedMarkerDiagnostic extends MarkerResolution {
  final String code;
  final String message;
  final AppSeverity severity;

  const ResolvedMarkerDiagnostic({
    required this.code,
    required this.message,
    required this.severity,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResolvedMarkerDiagnostic &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message &&
          severity == other.severity;

  @override
  int get hashCode => Object.hash(code, message, severity);
}

