import '../profiles/syntax_profile_id.dart';

final class LibraryMetrics {
  final int total;
  final Map<SyntaxProfileId, int> byProfile;

  const LibraryMetrics({required this.total, required this.byProfile});

  const LibraryMetrics.empty()
      : total = 0,
        byProfile = const {};

  int countOf(SyntaxProfileId profileId) => byProfile[profileId] ?? 0;
}
