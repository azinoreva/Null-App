//module name: server_model

library;

/// Shared value types for the server model.
///
/// These mirror the backend payloads exactly, so every layer that stores or
/// transports a server (API responses, the local server list, the database)
/// agrees on the same names, types and JSON keys. Anything that deserialises
/// a server should go through the `fromJson` factories here rather than
/// casting fields by hand.

/// Mirrors the backend's server visibility discriminator.
enum ServerType {
  private,
  public;

  static ServerType fromJson(String value) =>
      ServerType.values.firstWhere((e) => e.name == value);

  /// Lenient variant of [fromJson] used when reading persisted or
  /// user-editable data, where an unknown value must not throw.
  /// Returns null for anything that isn't a known server type.
  static ServerType? tryFromJson(Object? value) {
    if (value is ServerType) return value;
    if (value is! String) return null;
    for (final type in ServerType.values) {
      if (type.name == value) return type;
    }
    return null;
  }

  String toJson() => name;
}

/// Mirrors the kind of media a server accepts.
enum MediaType {
  image,
  video,
  audio;

  static MediaType fromJson(String value) =>
      MediaType.values.firstWhere((e) => e.name == value);

  /// Lenient variant of [fromJson]; see [ServerType.tryFromJson].
  static MediaType? tryFromJson(Object? value) {
    if (value is MediaType) return value;
    if (value is! String) return null;
    for (final type in MediaType.values) {
      if (type.name == value) return type;
    }
    return null;
  }

  String toJson() => name;
}

/// Mirrors backend `Media`: the media limits a server advertises.
///
/// `size` is in kilobytes and `timer` is in minutes.
class ServerMedia {
  final String url; // max 150 chars
  final int size; // kilobytes, 100..10000
  final int timer; // minutes, >= 10
  final List<MediaType> mediaType;

  const ServerMedia({
    required this.url,
    required this.size,
    required this.timer,
    required this.mediaType,
  });

  factory ServerMedia.fromJson(Map<String, dynamic> json) => ServerMedia(
        url: json['url'] as String,
        size: (json['size'] as num).toInt(),
        timer: (json['timer'] as num).toInt(),
        mediaType: (json['media_type'] as List<dynamic>? ?? const [])
            .map((e) => MediaType.fromJson(e as String))
            .toList(),
      );

  /// Tolerant parse used for persisted data: a media block missing or
  /// malformed yields null instead of throwing.
  static ServerMedia? tryFromJson(Object? value) {
    if (value == null) return null;
    if (value is ServerMedia) return value;
    if (value is! Map) return null;
    final json = Map<String, dynamic>.from(value);
    final url = json['url'];
    final size = json['size'];
    final timer = json['timer'];
    if (url is! String || size is! num || timer is! num) return null;
    return ServerMedia(
      url: url,
      size: size.toInt(),
      timer: timer.toInt(),
      mediaType: (json['media_type'] as List<dynamic>? ?? const [])
          .map(MediaType.tryFromJson)
          .nonNulls
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'size': size,
        'timer': timer,
        'media_type': mediaType.map((e) => e.toJson()).toList(),
      };

  ServerMedia copyWith({
    String? url,
    int? size,
    int? timer,
    List<MediaType>? mediaType,
  }) =>
      ServerMedia(
        url: url ?? this.url,
        size: size ?? this.size,
        timer: timer ?? this.timer,
        mediaType: mediaType ?? this.mediaType,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServerMedia &&
          other.url == url &&
          other.size == size &&
          other.timer == timer &&
          _listEquals(other.mediaType, mediaType));

  @override
  int get hashCode => Object.hash(url, size, timer, Object.hashAll(mediaType));

  @override
  String toString() => 'ServerMedia(url: $url, size: $size, timer: $timer)';
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
