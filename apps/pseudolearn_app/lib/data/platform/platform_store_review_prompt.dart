import 'package:in_app_review/in_app_review.dart';
import '../../domain/ports/store_review_prompt.dart';

final class PlatformStoreReviewPrompt implements StoreReviewPrompt {
  const PlatformStoreReviewPrompt();

  @override
  Future<void> request() async {
    try {
      if (!await InAppReview.instance.isAvailable()) return;
      await InAppReview.instance.requestReview();
    } catch (_) {
      return;
    }
  }
}
