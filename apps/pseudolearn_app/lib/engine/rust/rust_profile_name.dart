import '../../domain/model/profiles/syntax_profile_id.dart';

String rustProfileName(SyntaxProfileId profileId) => switch (profileId) {
  SyntaxProfileId.classicSpanish => 'es',
  SyntaxProfileId.english => 'en',
};
