
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

/// All feed categories. `name` is the storage id (matches the Python values).
enum Categories {
  // News & Current Affairs
  politics('Politics', CategoryGroup.news),
  government('Government', CategoryGroup.news),
  law('Law', CategoryGroup.news),
  news('News', CategoryGroup.news),
  world('World', CategoryGroup.news),
  local('Local', CategoryGroup.news),
  crime('Crime', CategoryGroup.news),
  weather('Weather', CategoryGroup.news),

  // Business & Economy
  business('Business', CategoryGroup.business),
  finance('Finance', CategoryGroup.business),
  investing('Investing', CategoryGroup.business),
  crypto('Crypto', CategoryGroup.business),
  markets('Markets', CategoryGroup.business),
  startups('Startups', CategoryGroup.business),
  economy('Economy', CategoryGroup.business),
  real_estate('Real Estate', CategoryGroup.business),
  jobs('Jobs', CategoryGroup.business),
  career('Career', CategoryGroup.business),

  // Tech & Science
  technology('Technology', CategoryGroup.tech),
  gadgets('Gadgets', CategoryGroup.tech),
  ai('AI', CategoryGroup.tech),
  software('Software', CategoryGroup.tech),
  cybersecurity('Cybersecurity', CategoryGroup.tech),
  science('Science', CategoryGroup.tech),
  space('Space', CategoryGroup.tech),
  environment('Environment', CategoryGroup.tech),
  climate('Climate', CategoryGroup.tech),

  // Health & Lifestyle
  health('Health', CategoryGroup.health),
  medicine('Medicine', CategoryGroup.health),
  nutrition('Nutrition', CategoryGroup.health),
  fitness('Fitness', CategoryGroup.health),
  wellness('Wellness', CategoryGroup.health),
  mental_health('Mental Health', CategoryGroup.health),
  parenting('Parenting', CategoryGroup.health),
  relationships('Relationships', CategoryGroup.health),
  lifestyle('Lifestyle', CategoryGroup.health),

  // Education & Learning
  education('Education', CategoryGroup.education),
  academic('Academic', CategoryGroup.education),
  learning('Learning', CategoryGroup.education),
  books('Books', CategoryGroup.education),
  languages('Languages', CategoryGroup.education),

  // Entertainment & Culture
  entertainment('Entertainment', CategoryGroup.entertainment),
  movies('Movies', CategoryGroup.entertainment),
  tv('TV', CategoryGroup.entertainment),
  music('Music', CategoryGroup.entertainment),
  art('Art', CategoryGroup.entertainment),
  theater('Theater', CategoryGroup.entertainment),
  celebrity('Celebrity', CategoryGroup.entertainment),
  pop_culture('Pop Culture', CategoryGroup.entertainment),

  // Sports
  sports('Sports', CategoryGroup.sports),
  football('Football', CategoryGroup.sports),
  basketball('Basketball', CategoryGroup.sports),
  soccer('Soccer', CategoryGroup.sports),
  tennis('Tennis', CategoryGroup.sports),
  motorsports('Motorsports', CategoryGroup.sports),
  esports('Esports', CategoryGroup.sports),
  gaming('Gaming', CategoryGroup.sports),

  // Other Interests
  travel('Travel', CategoryGroup.interests),
  food('Food', CategoryGroup.interests),
  cooking('Cooking', CategoryGroup.interests),
  drinks('Drinks', CategoryGroup.interests),
  fashion('Fashion', CategoryGroup.interests),
  beauty('Beauty', CategoryGroup.interests),
  home_garden('Home & Garden', CategoryGroup.interests),
  diy('DIY', CategoryGroup.interests),
  automotive('Automotive', CategoryGroup.interests),
  pets('Pets', CategoryGroup.interests),
  animals('Animals', CategoryGroup.interests),
  hobbies('Hobbies', CategoryGroup.interests),
  photography('Photography', CategoryGroup.interests),

  // Society
  religion('Religion', CategoryGroup.society),
  spirituality('Spirituality', CategoryGroup.society),
  social('Social', CategoryGroup.society),
  community('Community', CategoryGroup.society),
  activism('Activism', CategoryGroup.society),
  history('History', CategoryGroup.society);

  const Categories(this.label, this.group);

  /// Human readable name, e.g. "Pop Culture".
  final String label;

  /// Section this category belongs to in the picker.
  final CategoryGroup group;

  /// Stable id used for persistence.
  String get id => name;

  /// Parses a stored id. Returns `null` for unknown/removed categories.
  static Categories? fromId(String id) {
    for (final c in Categories.values) {
      if (c.name == id) return c;
    }
    return null;
  }

  /// All categories grouped for a sectioned list UI.
  static Map<CategoryGroup, List<Categories>> get grouped {
    final map = <CategoryGroup, List<Categories>>{};
    for (final c in Categories.values) {
      map.putIfAbsent(c.group, () => <Categories>[]).add(c);
    }
    return map;
  }
}