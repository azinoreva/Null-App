import '../../network/updates/updates_categories.dart';

/// Groups used to section the feed-control picker UI.
enum CategoryGroup {
  news('News & Current Affairs'),
  business('Business & Economy'),
  tech('Tech & Science'),
  health('Health & Lifestyle'),
  education('Education & Learning'),
  entertainment('Entertainment & Culture'),
  sports('Sports'),
  interests('Other Interests'),
  society('Society');

  const CategoryGroup(this.label);

  final String label;
}

/// A feed category. The available IDs come from the backend's
/// `/api/sub-categories` response, cached in Hive by [UpdatesCategoriesService].
/// IDs remain the stable values stored in SharedPreferences and sent to APIs.
class Categories {
  const Categories._(this.id, this.label, this.group, this.subcategories);

  final String id;
  final String label;
  final CategoryGroup group;
  final List<String> subcategories;

  /// Current backend categories in the order returned by the service.
  static List<Categories> get values {
    final entries = UpdatesCategoriesService.instance.categoryEntries;
    return entries.entries
        .map((entry) => Categories._(
              entry.key,
              _labelFor(entry.key),
              _groupFor(entry.key),
              entry.value,
            ))
        .toList(growable: false);
  }

  static Categories? fromId(String id) {
    final subcategories =
        UpdatesCategoriesService.instance.categoryEntries[id];
    if (subcategories == null) return null;
    return Categories._(id, _labelFor(id), _groupFor(id), subcategories);
  }

  static String _labelFor(String id) => id
      .split(RegExp(r'[-_]'))
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');

  // Keep familiar sections for current category IDs. New backend IDs appear
  // automatically and use the general interests section until classified.
  static CategoryGroup _groupFor(String id) {
    const groups = <CategoryGroup, Set<String>>{
      CategoryGroup.news: {
        'politics', 'government', 'law', 'news', 'world', 'local', 'crime',
        'weather', 'disaster',
      },
      CategoryGroup.business: {
        'business', 'finance', 'investing', 'crypto', 'markets', 'startups',
        'economy', 'real_estate', 'jobs', 'career',
      },
      CategoryGroup.tech: {
        'technology', 'gadgets', 'ai', 'software', 'cybersecurity', 'science',
        'space', 'environment', 'climate',
      },
      CategoryGroup.health: {
        'health', 'medicine', 'nutrition', 'fitness', 'wellness',
        'mental_health', 'parenting', 'relationships', 'lifestyle',
      },
      CategoryGroup.education: {'education', 'academic', 'learning', 'books', 'languages'},
      CategoryGroup.entertainment: {
        'entertainment', 'movies', 'tv', 'music', 'art', 'theater', 'celebrity',
        'pop_culture',
      },
      CategoryGroup.sports: {
        'sports', 'football', 'basketball', 'soccer', 'tennis', 'motorsports',
        'esports', 'gaming',
      },
      CategoryGroup.interests: {
        'travel', 'food', 'cooking', 'drinks', 'fashion', 'beauty',
        'home_garden', 'diy', 'automotive', 'pets', 'animals', 'hobbies',
        'photography',
      },
      CategoryGroup.society: {
        'religion', 'spirituality', 'social', 'community', 'activism', 'history',
      },
    };
    for (final entry in groups.entries) {
      if (entry.value.contains(id)) return entry.key;
    }
    return CategoryGroup.interests;
  }

  @override
  bool operator ==(Object other) => other is Categories && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
