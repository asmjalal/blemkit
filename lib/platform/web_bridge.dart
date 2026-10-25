// Browser-only APIs (localStorage, file download, context menu) behind a
// conditional import, so the rest of the app compiles on the VM for tests.
export 'web_bridge_stub.dart' if (dart.library.js_interop) 'web_bridge_web.dart';
