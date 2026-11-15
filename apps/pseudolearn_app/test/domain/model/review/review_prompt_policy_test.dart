import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/review/review_prompt_policy.dart';

void main() {
  group('ReviewPromptPolicy.standard', () {
    const policy = ReviewPromptPolicy.standard;

    test('treats the first, tenth and thirtieth solved exercise as milestones', () {
      expect(policy.isMilestone(1), isTrue);
      expect(policy.isMilestone(10), isTrue);
      expect(policy.isMilestone(30), isTrue);
    });

    test('ignores counts between milestones', () {
      expect(policy.isMilestone(2), isFalse);
      expect(policy.isMilestone(9), isFalse);
      expect(policy.isMilestone(11), isFalse);
      expect(policy.isMilestone(29), isFalse);
    });

    test('ignores zero, negative and counts beyond the last milestone', () {
      expect(policy.isMilestone(0), isFalse);
      expect(policy.isMilestone(-1), isFalse);
      expect(policy.isMilestone(31), isFalse);
      expect(policy.isMilestone(95), isFalse);
    });
  });

  test('a policy without milestones never prompts', () {
    const policy = ReviewPromptPolicy({});

    expect(policy.isMilestone(1), isFalse);
  });
}
