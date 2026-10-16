import '../../engine/functions/settings/categories.dart';
import '../../engine/network/updates/check_updates.dart';
import 'filter_model.dart';

/// Applies the user's feed-category selection to server and cached updates.
class FeedFilter {
  FeedFilter._();

  static final FeedFilter instance = FeedFilter._();

  Future<List<Update>> apply({
    required Iterable<Update> updates,
    required Iterable<Categories> selectedCategories,
  }) async {
    final selected = selectedCategories.toList(growable: false);
    final selectedIds = selected.map((category) => category.id.toLowerCase().trim()).toSet();
    final result = <Update>[];

    for (final update in updates) {
      final categoryId = update.category?.trim();
      if (categoryId != null && categoryId.isNotEmpty) {
        if (selectedIds.contains(categoryId.toLowerCase())) {
          result.add(update);
        }
        continue;
      }

      final content = <String>[
        update.text,
        if (update.hashtag.trim().isNotEmpty) update.hashtag,
        if (update.media?.mediaDescription.trim().isNotEmpty ?? false)
          update.media!.mediaDescription,
      ].join(' ');
      try {
        if (await FilterModel.instance.matchesSelectedCategory(content, selected)) {
          result.add(update);
        }
      } catch (_) {
        // If local inference fails, do not let an unclassified update bypass
        // the user's category selection.
      }
    }
    return result;
  }
}
