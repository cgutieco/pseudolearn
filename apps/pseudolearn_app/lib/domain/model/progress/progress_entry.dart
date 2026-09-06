final class ProgressEntry {
  final String contentId;
  final bool visited;
  final bool completed;
  final DateTime? firstVisitedAt;
  final DateTime? firstCompletedAt;

  const ProgressEntry({
    required this.contentId,
    required this.visited,
    required this.completed,
    this.firstVisitedAt,
    this.firstCompletedAt,
  });

  ProgressEntry copyWith({
    String? contentId,
    bool? visited,
    bool? completed,
    DateTime? firstVisitedAt,
    DateTime? firstCompletedAt,
  }) {
    return ProgressEntry(
      contentId: contentId ?? this.contentId,
      visited: visited ?? this.visited,
      completed: completed ?? this.completed,
      firstVisitedAt: firstVisitedAt ?? this.firstVisitedAt,
      firstCompletedAt: firstCompletedAt ?? this.firstCompletedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'content_id': contentId,
        'visited': visited,
        'completed': completed,
        'first_visited_at': firstVisitedAt?.toIso8601String(),
        'first_completed_at': firstCompletedAt?.toIso8601String(),
      };

  factory ProgressEntry.fromJson(Map<String, dynamic> json) {
    return ProgressEntry(
      contentId: json['content_id'] as String,
      visited: json['visited'] as bool? ?? false,
      completed: json['completed'] as bool? ?? false,
      firstVisitedAt: json['first_visited_at'] != null
          ? DateTime.parse(json['first_visited_at'] as String)
          : null,
      firstCompletedAt: json['first_completed_at'] != null
          ? DateTime.parse(json['first_completed_at'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressEntry &&
          runtimeType == other.runtimeType &&
          contentId == other.contentId &&
          visited == other.visited &&
          completed == other.completed &&
          firstVisitedAt == other.firstVisitedAt &&
          firstCompletedAt == other.firstCompletedAt;

  @override
  int get hashCode => Object.hash(
        contentId,
        visited,
        completed,
        firstVisitedAt,
        firstCompletedAt,
      );
}
