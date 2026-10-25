/// Build-time configuration for the SynappKit editor itself.
///
/// Override per environment with `--dart-define`, for example:
///   flutter run -d chrome --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
/// The defaults point at the shared development project.
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://yqrdwakbgywgzffcrquv.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlxcmR3YWtiZ3l3Z3pmZmNycXV2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg5NzM4NzIsImV4cCI6MjA5NDU0OTg3Mn0.IT1l_iR-8JlV7E7elAZHejKcRHELfQSH6a6IdXlZKPk',
  );

  /// Optional proxy (for example a Supabase Edge Function) that forwards AI
  /// requests so provider keys never reach the browser. Empty means the editor
  /// calls the provider directly with the user's own key.
  static const String aiProxyUrl = String.fromEnvironment('AI_PROXY_URL');
}
