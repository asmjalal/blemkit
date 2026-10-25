# CLAUDE.md

This file gives Claude Code the context it needs to work in this repository.

## What this project is

**SynappKit** (package name `designflutterkit`) is a FlutterFlow-style visual app builder written in Flutter and run as a **Flutter Web** app. Users design pages on a device canvas, add logic (state, actions, API calls, auth, custom code), try it in **Test mode**, and export a complete, compiling Flutter project as a `.zip` or a GitHub commit.

- **Editor auth:** Firebase Auth (Google sign-in). User profile and per-user AI keys live in Firestore `users/{uid}`.
- **Persistence:** Supabase tables `projects`, `screens` (plus a `__settings__` pseudo-row per project), `templates`, `categories`, `downloads`, and, after running `supabase/migrations/*`, `project_versions`, `project_comments`, `user_roles`. `projects.user_id` is the **Firebase UID**.
- **Local cache:** browser `localStorage` under `design_flutter_kit_root*`, accessed only through `lib/platform/web_bridge.dart`.
- **AI:** Claude (`lib/services/claude_client.dart`, raw HTTP to the Messages API) plus OpenAI-compatible providers in `lib/services/ai_generation_service.dart`. Optional server-side proxy: `supabase/functions/ai-proxy`, enabled with `--dart-define=AI_PROXY_URL=...`.

## Commands

```bash
flutter pub get
flutter run -d chrome                               # the editor
flutter run -d chrome -t tool/ui_preview/main.dart  # screens without sign-in: #builder=<template>, #dashboard, #theme, #settings, #logic=<section>
flutter analyze lib test tool                       # pass paths so stale build/ output is not analyzed
flutter test                                        # VM tests (no dart:html anywhere in lib/)
tool/check_export.sh [name]                         # export every template + kitchen sink + logic fixture and analyze each generated project
dart run tool/embed_runtime.dart                    # after editing lib/runtime/exported/*
dart run build_runner build --delete-conflicting-outputs   # regenerates lib/models/widget_node.g.dart
```

Config is in `lib/app_config.dart` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `AI_PROXY_URL` via `--dart-define`). CI (`.github/workflows/ci.yml`) runs analyze, tests, the export check and a web build.

## Architecture

### The widget tree

Everything is a tree of `WidgetNode { id, type, properties, children }` ([lib/models/widget_node.dart](lib/models/widget_node.dart)).

- A **page** is a root node (usually `Scaffold`). `properties['pageName']` holds its name. Page logic lives on the root: `pageParams`, `pageState` (lists of `FieldDef` JSON), `onPageLoad` (actions).
- A **component** is a root node in `provider.components` with `componentName`, `pageParams` (parameters, including `Action` callbacks) and `pageState`. It is used through `ComponentInstance` nodes (`componentId`, `args`).
- Colors are AARRGGBB ints/strings, `0x`/`#` hex, or theme keys (`primaryColor`). Parse them with `ColorUtils.parseColor` (canvas) or `formatColor` (generators).
- Legacy palette names are mapped on load (`WidgetNode._legacyTypes`).

Logic properties any widget may carry (all editor-only, see `BaseWidgetGenerator.editorOnlyKeys`):
`actions` (on tap), `onLongPress`, `onDoubleTap`, `onChanged`, `onSubmitted`, `bindings` (`{prop: value}`), `visibility` (`{condition, hideOn}`), `animation` (`{type, durationMs, delayMs}`), `semanticLabel`, `apiQuery` (list from an API call), `backendQuery`/`dataBinding` (Supabase).

### Logic model

- Project-wide logic is `ProjectLogic` ([lib/models/project_logic.dart](lib/models/project_logic.dart)): app state, data types, enums, API calls, custom code, environments, packages, auth, languages and translations, RTL, theme mode, and app icon. It is stored in `provider.logic` and persisted with the project (localStorage, `__settings__` row, version snapshots).
- **Values and conditions** are plain JSON maps documented in [lib/logic/logic_values.dart](lib/logic/logic_values.dart), for example `{'source': 'appState', 'name': 'count'}`.
- **Actions** are defined once in `ActionCatalog` (same file). Three places implement each action type and must stay in step:
  1. the editor form, in [action_flow_editor.dart](lib/widgets/property_editors/action_flow_editor.dart), driven by `ActionParamSpec`;
  2. the canvas preview, in [lib/runtime/preview_runtime.dart](lib/runtime/preview_runtime.dart) (`_runOne`);
  3. the export, in [lib/generators/logic_codegen.dart](lib/generators/logic_codegen.dart) (`_action`).

### Two pipelines over the same tree

| Pipeline | Location | Purpose |
|---|---|---|
| Canvas builders | [lib/widgets/canvas_preview/builders/](lib/widgets/canvas_preview/builders/) via `WidgetBuilderFactory` | Live, selectable preview. In Test mode (`CanvasPreviewMode`), it runs actions through `PreviewRuntime` |
| Code generators | [lib/generators/](lib/generators/) via `WidgetGeneratorRegistry` | Dart source for export |

- `WidgetBuilderFactory.buildWidget` and `WidgetGeneratorRegistry.generateCode` both apply the shared wrappers (bindings, visibility, entrance animation, semantics, gestures). Change them together.
- Bound properties reach generators as `BoundValue`. `dartString`, `formatColor` and numeric interpolation turn them into expressions. If a generator throws on one, the registry falls back to literal values.
- [ProjectGenerator.generateFullProject](lib/generators/project_generator.dart) writes `main.dart`, pages, `components/`, `app_state.dart`, `theme.dart` (light + dark, spacing/radius tokens, google_fonts), `backend/api_calls.dart`, `backend/schema/data_types.dart`, `custom_code/`, `env.dart`, `l10n/translations.dart`, `auth_gate.dart`, `supabase_service.dart`, and `synapp/` (the runtime). It also adds package dependencies based on what the project uses.
- **Runtime library:** `lib/runtime/exported/synapp_utils.dart` and `synapp_widgets.dart` are real Dart files that the canvas uses. `tool/embed_runtime.dart` copies them into `lib/generators/runtime_sources.g.dart` for the export. They may only depend on the Flutter SDK.
- `ExportBundle` ([lib/services/export_bundle.dart](lib/services/export_bundle.dart)) merges generated files into `assets/base_template.zip`. Both the zip download and `GitHubExporter` use it.

### State

There is one `ChangeNotifierProvider<WidgetTreeProvider>` ([lib/providers/widget_tree_provider.dart](lib/providers/widget_tree_provider.dart)). It holds pages, components, selection, theme tokens, `logic`, Supabase connection and queries, undo/redo, clipboard, preview runtime state (`testMode`, `preview*` maps, `previewDevice`, `previewDarkMode`) and version/comment helpers.

- Use `setNodeProperty(node, key, value)` for property edits (it persists).
- Use `updateLogic((l) => ...)` for project logic.
- `previewChanged()` rebuilds the canvas without marking the project dirty.

### Editor UI

- The design system is in `lib/ui/editor_theme.dart` (`EditorColors`, `EditorTheme.dark()`, applied app-wide) and `lib/ui/editor_widgets.dart` (`EditorSection`, `EditorField`, `EditorTextInput`, `EditorDropdown`, `EditorPill`, …). Use these, not hard-coded colors.
- Screens: `login` → `dashboard` → `builder`.
  - The builder has a top bar, a sidebar (palette / tree / pages + components / theme / data), the canvas with its device toolbar and Test mode, and a properties panel with Properties / Actions / Logic tabs.
  - Panels: AI, comments.
  - Overlays: ⌘K palette, storyboard, version history, shortcuts, welcome tour.
  - Separate screens: `project_logic_screen` (Logic & Data), `theme_settings_screen`, `app_settings_screen`.

## Adding a widget type

1. Generator registered in [widget_generator_registry.dart](lib/generators/widget_generator_registry.dart). For widgets backed by the runtime, add a class to `synapp_widget_generators.dart`.
2. Canvas builder registered in `WidgetBuilderFactory.initialize()`. Runtime-backed widgets go in `synapp_widget_builders.dart`.
3. Defaults in `WidgetTreeEditor.createWidgetNodeWithDefaults`.
4. Palette entry in `WidgetSidebar.paletteCategories` ([widget_side_bar.dart](lib/widgets/widget_sidebar/widget_side_bar.dart)).
5. Property editors: `_getSpecificEditors` in [properties_panel.dart](lib/widgets/properties_panel.dart). Optionally, add bindable keys to `_bindableByType` in `widget_logic_panel.dart`.
6. If it holds input, add a widget-state variable in `LogicCodegen._widgetStateExpr` and `kInputWidgetTypes`.
7. Optionally, add it to the AI system prompt in `ai_generation_service.dart`.

`test/generators/palette_widgets_test.dart` fails if a palette entry has no builder or generator. `tool/check_export.sh kitchen_sink` checks that every palette widget's export compiles.

## Gotchas

- Generators still share static state (`BaseWidgetGenerator.*`, `ProjectGenerator.*`, `LogicCodegen.*`). `generateFullProject` resets it, and `generateScreen` resets the per-screen parts. Generation is not re-entrant.
- Generated user text must go through `dartString()`/`escapeString()`, never raw `'$value'`.
- Saving inserts new screen rows, then deletes the old ones (not transactional, but it never leaves zero screens).
- `serviceRoleKey` is never persisted (`toPersistedJson`). Do not log or export keys.
- RLS cannot be tied to users: the editor signs in with Firebase, while Supabase sees the anon key. See the note in the migration.
- Exported code is checked offline against the local pub cache. A new export dependency must be cached (or CI must run online) for `tool/check_export.sh` to pass.

## Roadmap

[FLUTTERFLOW_GAP_ANALYSIS.md](FLUTTERFLOW_GAP_ANALYSIS.md) lists feature parity with FlutterFlow, with an implementation status per task.
