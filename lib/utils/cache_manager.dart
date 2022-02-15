class CacheManager {
  static final CacheManager _singleton = CacheManager._internal();

  factory CacheManager() {
    return _singleton;
  }

  CacheManager._internal();

  static Map<String, dynamic> cacheStore = {};

  static void cacheData(String name, dynamic data) async {
    cacheStore[name] = {
      'data': data,
    };
  }

  static dynamic getData(String name) {
    if (cacheStore[name] == null) return null;
    return cacheStore[name]['data'];
  }

  static void removeData(String name) async {
    cacheStore[name] = null;
  }

  static void clear() async {
    cacheStore = {};
  }
}
