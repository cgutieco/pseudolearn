final class ProgressEntry {
  final String contentId;
  final bool visited;
  final bool completed;
  final DateTime? firstVisitedAt;
  final DateTime? firstCompletedAt;
  final bool assisted;

  const ProgressEntry({
    required this.contentId,
    required this.visited,
    required this.completed,
    this.firstVisitedAt,
    this.firstCompletedAt,
    this.assisted = false,
  });

  ProgressEntry copyWith({
    String? contentId,
    bool? visited,
    bool? completed,
    DateTime? firstVisitedAt,
    DateTime? firstCompletedAt,
    bool? assisted,
  }) {
    return ProgressEntry(
      contentId: contentId ?? this.contentId,
      visited: visited ?? this.visited,
      completed: completed ?? this.completed,
      firstVisitedAt: firstVisitedAt ?? this.firstVisitedAt,
      firstCompletedAt: firstCompletedAt ?? this.firstCompletedAt,
      assisted: assisted ?? this.assisted,
    );
  }

  Map<String, dynamic> toJson() => {
        'content_id': contentId,
        'visited': visited,
        'completed': completed,
        'first_visited_at': firstVisitedAt?.toIso8601String(),
        'first_completed_at': firstCompletedAt?.toIso8601String(),
        'assisted': assisted,
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
      assisted: json['assisted'] as bool? ?? false,
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
          firstCompletedAt == other.firstCompletedAt &&
          assisted == other.assisted;

  @override
  int get hashCode => Object.hash(
        contentId,
        visited,
        completed,
        firstVisitedAt,
        firstCompletedAt,
        assisted,
      );
}
