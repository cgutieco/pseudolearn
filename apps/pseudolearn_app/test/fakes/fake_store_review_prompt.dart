import 'package:pseudolearn_app/domain/ports/store_review_prompt.dart';

final class FakeStoreReviewPrompt implements StoreReviewPrompt {
  int requests = 0;

  @override
  Future<void> request() async {
    requests++;
  }
}
