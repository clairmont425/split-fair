import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Smart in-app review prompt using Apple's SKStoreReviewController via the
/// `in_app_review` package.
///
/// Apple guidance:
/// - Max 3 prompts per user per 365-day window — Apple ENFORCES this in the
///   StoreKit API; if you ask more, the call silently no-ops.
/// - Prompt at moments of value, not on app launch.
/// - You cannot guarantee the prompt actually shows (Apple may suppress it).
///
/// Our policy:
/// - Trigger after the user has seen a successful fair-split result.
/// - Prompt at the 2nd, 5th, and 10th completed calculations only.
/// - Never re-prompt within 90 days of the last prompt (defensive — Apple
///   already gates this, but we keep our own counter so a TestFlight reset
///   doesn't blow the user's quota).
///
/// Call [requestReviewIfAppropriate] from the results screen — it will no-op
/// if the user is not at a trigger threshold.
class ReviewService {
  ReviewService._();

  static const _completedCalcKey = 'review_completed_calc_count';
  static const _lastPromptKey = 'review_last_prompt_iso';
  static const _everPromptedKey = 'review_ever_prompted';

  static const _triggerThresholds = {2, 5, 10};
  static const _minDaysBetweenPrompts = 90;

  static final InAppReview _inAppReview = InAppReview.instance;

  /// Increment the calc count and request a review if we are at a trigger
  /// threshold. Safe to call after every successful result render.
  static Future<void> requestReviewIfAppropriate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newCount = (prefs.getInt(_completedCalcKey) ?? 0) + 1;
      await prefs.setInt(_completedCalcKey, newCount);

      if (!_triggerThresholds.contains(newCount)) return;

      final lastIso = prefs.getString(_lastPromptKey);
      if (lastIso != null) {
        final last = DateTime.tryParse(lastIso);
        if (last != null &&
            DateTime.now().difference(last).inDays < _minDaysBetweenPrompts) {
          return;
        }
      }

      if (!await _inAppReview.isAvailable()) return;

      await _inAppReview.requestReview();
      await prefs.setString(_lastPromptKey, DateTime.now().toIso8601String());
      await prefs.setBool(_everPromptedKey, true);
    } catch (_) {
      // Never let a review failure crash the app or interrupt the user.
    }
  }

  /// Fallback: opens the App Store review page directly.
  /// Use this from a Settings → "Rate Split Fair" menu item.
  static Future<void> openStoreListing() async {
    try {
      if (!await _inAppReview.isAvailable()) return;
      await _inAppReview.openStoreListing(
        appStoreId: '6761033612',
      );
    } catch (_) {}
  }
}
