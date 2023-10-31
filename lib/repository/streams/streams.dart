class UserProfilePictureCache {
  static final UserProfilePictureCache _instance =
      UserProfilePictureCache._internal();

  factory UserProfilePictureCache() {
    return _instance;
  }

  UserProfilePictureCache._internal();

  final Map<String, String> _cache = {};

  void updateCache(String userId, String profilePictureURL) {
    _cache[userId] = profilePictureURL;
  }

  String? getFromCache(String userId) {
    return _cache[userId];
  }
}
