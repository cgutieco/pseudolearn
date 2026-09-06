enum LearningTrack {
  foundations('A'),
  imperative('B'),
  objectOriented('C');

  final String code;

  const LearningTrack(this.code);

  static LearningTrack? fromCode(String code) {
    for (final track in values) {
      if (track.code == code) return track;
    }
    return null;
  }
}
