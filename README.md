# SynappKit

A visual builder for Flutter apps. You can design pages, add logic, test them in the browser, and export a complete Flutter project.

## Run the editor

1. Install Flutter (stable).
2. `flutter pub get`
3. `flutter run -d chrome`

To use your own Supabase project for the editor:

```
flutter run -d chrome --dart-define=SUPABASE_URL=https://xyz.supabase.co --dart-define=SUPABASE_ANON_KEY=...
```

To preview screens without signing in, use `flutter run -d chrome -t tool/ui_preview/main.dart` and open `#dashboard`, `#builder=food_delivery`, `#theme`, `#settings` or `#logic=api`.

## One-time database setup

In the Supabase SQL editor, run `supabase/schema.sql` and then `supabase/migrations/20261025_project_versions_roles_comments.sql`. The migration adds version history, comments and admin roles.

The optional AI proxy keeps provider keys on the server. Deploy it with `supabase functions deploy ai-proxy` (instructions are at the top of `supabase/functions/ai-proxy/index.ts`). Then build the editor with `--dart-define=AI_PROXY_URL=...`.

## Checks

```
flutter analyze lib test tool
flutter test
tool/check_export.sh        # exports every template and checks the generated code compiles
```

## Documentation

- [CLAUDE.md](CLAUDE.md): architecture and conventions.
- [FLUTTERFLOW_GAP_ANALYSIS.md](FLUTTERFLOW_GAP_ANALYSIS.md): feature comparison with FlutterFlow and the status of each item.
