/// In-memory fallback used on the VM (tests) and on non-web platforms.
class WebBridge {
  static final Map<String, String> _memory = {};

  static String? read(String key) => _memory[key];

  static void write(String key, String value) => _memory[key] = value;

  static void remove(String key) => _memory.remove(key);

  /// Returns false when the platform cannot trigger a browser download.
  static bool downloadBytes(List<int> bytes, String fileName) => false;

  static void suppressContextMenu() {}
}
