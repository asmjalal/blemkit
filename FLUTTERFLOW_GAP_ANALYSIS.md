# FlutterFlow Feature Parity: Gap Analysis & Task Backlog

> Compares **SynappKit** (this repo, branch `feature/new_improvements`) with **FlutterFlow** ([flutterflow.io](https://www.flutterflow.io/), [docs](https://docs.flutterflow.io/), [pricing](https://www.flutterflow.io/pricing)) as of **2026-10-24**.
> SynappKit's status was checked against the source code, not against marketing copy. Each row cites the file that supports it.

**Legend:** ✅ Have · 🟡 Partial · ❌ Missing · **Effort:** S (≤2 days) · M (≤1 week) · L (≤3 weeks) · XL (more than 3 weeks)

---

## 0. Implementation status (updated 2026-10-25)

Sections 1–5 below describe the **baseline from 2026-10-24**. This section records what has been built since then.

How it was verified:
- `flutter test`: 30 tests pass, including the canvas runtime and component tests.
- `tool/check_export.sh`: all 14 templates, a "kitchen sink" with every palette widget, and a fixture that uses every logic feature export to Flutter projects that pass `flutter analyze` with no errors.
- `flutter build web` succeeds.

### Updated scorecard

| Area | Before | Now |
|---|---|---|
| Visual UI builder | ~55% | ~75%: device presets (phone, tablet, desktop), storyboard, ⌘K, copy/paste, all palette widgets work |
| Design system | ~40% | ~70%: dark mode tokens, spacing and radius tokens, Google Fonts, palette generator |
| Components | ~15% | ~70%: parameters, callbacks, state, instances, export (no child slots or library publishing) |
| State management | ~10% | ~85%: app, page and component state, persisted app state, data types, enums, bindings |
| Navigation | ~35% | ~60%: typed page parameters, replace, home and login pages, auth gate (no go_router or deep links) |
| Actions & logic | ~10% | ~75%: 30 action types, 6 triggers, if/else, outputs, custom actions |
| Backend: Supabase | ~50% | ~70%: auth, RPC, storage upload (no pagination) |
| Backend: Firebase | 0% | 0% |
| REST APIs | ~5% | ~65%: definitions, variables, test runner, JSON paths, actions, list binding |
| Custom code | 0% | ~65%: functions, actions, widgets, packages (no in-browser analysis) |
| AI | ~40% | ~60%: Claude provider, selected-widget edits, screenshot to UI, proxy option |
| Testing | ~15% | ~55%: interactive Test mode with debug panel; compile checks in CI |
| Collaboration | 0% | ~25%: version history and comments (need the SQL migration) |
| Export & deploy | ~25% | ~45%: GitHub push, icon and splash config, compile-checked export |
| Integrations | 0% | ~10%: launch URL, share, clipboard, haptics |
| Accessibility & i18n | 0% | ~55%: translations, language switching, RTL, semantic labels |

### Status per task

**Phase 0: platform debt**

| ID | Status | Notes |
|---|---|---|
| P0-01 | ✅ | `lib/app_config.dart` reads `--dart-define`. The dev keys remain as defaults and are still in git history, so rotate them. |
| P0-02 | 🟡 | The service-role key is never persisted (`toPersistedJson`). Supabase OAuth/PAT through an Edge Function is not built. |
| P0-03 | 🟡 | `supabase/functions/ai-proxy` and client support (`AI_PROXY_URL`) are written. The function is not deployed, and per-user quotas are not implemented. |
| P0-04 | ✅ | Save inserts new rows first, then deletes the old ones. |
| P0-05 | ✅ | All `dart:html` use goes through `lib/platform/web_bridge.dart` (`package:web`). Tests run on the VM. |
| P0-06 | ✅ | The default counter test was replaced. Runtime, palette, template and logic export tests were added. |
| P0-07 | ✅ | `tool/check_export.sh` and `.github/workflows/ci.yml`. |
| P0-08 | ✅ | `ProjectLogic.schemaVersion`. Legacy node types are migrated on load. |
| P0-09 | 🟡 | Generator state resets on every run. Statics remain; a full `GenerationContext` refactor was not done. |
| P0-10 | 🟡 | A `user_roles` table and client check, falling back to the e-mail rule. RLS policies still use e-mail patterns. |
| P0-11 | ✅ | Dead files removed. |
| P0-12 | 🟡 | The export now has `backend/`, `components/`, `custom_code/`, `synapp/` and `l10n/`. Pages are still flat in `lib/`. |

**Phase 1: logic**

| ID | Status | Notes |
|---|---|---|
| F1-01 | ✅ | App state (persisted with shared_preferences), page state and component state. |
| F1-02 | ✅ | A Bindings section in the Logic tab, with 12 value sources. Limited to known-safe properties per widget. |
| F1-03 | ✅ | Condition plus "hide on phone, tablet or desktop". |
| F1-04 | ✅ | 30 actions in 7 categories; on tap, long press, double tap, change, submit and page load; if/else; API outputs. The UI is a nested list, not a node graph. |
| F1-05 | ✅ | Typed parameters, passed from Navigate. |
| F1-06 | ✅ | Data types and enums, exported with `fromMap`/`toMap`. |

**Phase 2: backend**

| ID | Status | Notes |
|---|---|---|
| F2-01 | 🟡 | Variables, headers, body, a Test tab, JSON paths, an API Call action and list binding. Missing: OpenAPI/cURL import, API groups, private calls. |
| F2-02 | ✅ | Supabase Auth: sign in, sign up, reset password, sign out, auth gate, user values. |
| F2-03 | 🟡 | RPC and storage upload actions. No pagination, and filters cannot use bindings. |
| F2-04 | ⏭ Skipped | Firebase/Firestore backend (XL; needs a schema design decision). |
| F2-05 | ✅ | Environments with `--dart-define=APP_ENV`. |

**Phase 3: design**

| ID | Status | Notes |
|---|---|---|
| F3-01 | ✅ | Components with typed and callback parameters, state, instances, "edit master". Missing: child slots, library publishing. |
| F3-02 | 🟡 | Five device presets and breakpoint visibility. No per-breakpoint property values. |
| F3-03 | ✅ | Dark tokens, `darkTheme`/`themeMode`, canvas preview, a toggle action. |
| F3-04 | 🟡 | Entrance animations (canvas and export). No page transitions or on-action animations. |
| F3-05 | 🟡 | Google Fonts picker, loaded in the export. The canvas shows a fallback font. No font or icon-pack upload. |
| F3-06 | ✅ | Spacing and radius tokens. |
| F3-07 | ⏭ Skipped | Figma import (needs a Figma token and import design). |
| F3-08 | 🟡 | Storyboard, ⌘K, copy/paste, duplicate, shortcuts. No multi-select, rulers or overflow warnings. |
| F3-09 | 🟡 | 24 placeholder palette entries now work (RatingBar, PinCode, Counter, ChoiceChips, CheckboxGroup, RadioGroup, Signature, DataTable, CreditCardForm, PlacePicker, SlidableListTile, LoadingOverlay, Hero, animated widgets, Flex…). WebView, video, charts, maps and Lottie need new packages, which was not decided. |

**Phase 4: custom code**

| ID | Status | Notes |
|---|---|---|
| F4-01 | ✅ | Functions, actions and widgets with arguments and return types. Plain-text editor with no live analysis. |
| F4-02 | ✅ | Packages section. |
| F4-03 | 🟡 | Offline compile check and CI. No compile service inside the editor. |

**Phase 5: AI**

| ID | Status | Notes |
|---|---|---|
| F5-01 | 🟡 | "Only selected widget" scope. No diff preview. |
| F5-02 | ✅ | Screenshot to UI (Claude, OpenAI, Gemini). |
| F5-03 | ⏭ Skipped | Agent mode. |
| F5-04 | 🟡 | Palette generator (algorithmic, no AI). |
| F5-05 | ⏭ Skipped | MCP server. |
| F5-06 | ✅ | Claude Opus 5.5 provider with server-side refusal fallback. |

**Phase 6: test, run & ship**

| ID | Status | Notes |
|---|---|---|
| F6-01 | ⏭ Skipped | Run mode (needs build servers). |
| F6-02 | ✅ | Test mode with debug panel and action log. |
| F6-03 | ✅ | Push to GitHub with a personal access token. |
| F6-04 | ⏭ Skipped | Hosting (needs infrastructure). |
| F6-05 | ✅ | Icon and splash configuration. |
| F6-06 | ⏭ Skipped | Store builds (needs infrastructure and accounts). |
| F6-07 | 🟡 | Every export is compile-checked and many generator bugs are fixed. No go_router. |

**Phase 7: collaboration**

| ID | Status | Notes |
|---|---|---|
| F7-01 | ✅ | Version history (run the migration first). |
| F7-02 | ⏭ Skipped | Teams (needs an auth model decision; see the migration note). |
| F7-03 | ✅ | Comments (run the migration first). |
| F7-04 | ⏭ Skipped | Real-time collaboration. |
| F7-05 | ⏭ Skipped | Branching. |

**Phase 8: integrations**

| ID | Status | Notes |
|---|---|---|
| F8-01 to F8-07, F8-09 | ⏭ Skipped | Each needs third-party accounts or API keys. |
| F8-08 | 🟡 | Share, launch URL, clipboard and haptics. No local notifications. |

**Phase 9: accessibility, i18n & business**

| ID | Status | Notes |
|---|---|---|
| F9-01 | 🟡 | Languages, translations and Set Language; exported as `tr()`. No ARB/intl files and no AI translate-all. |
| F9-02 | ✅ | RTL. |
| F9-03 | 🟡 | Semantic labels. No accessibility lint. |
| F9-04 | ⏭ Skipped | Billing (business decision). |
| F9-05 | ⏭ Skipped | Component marketplace. |
| F9-06 | ✅ | Welcome tour, shortcuts and ⌘K. |

**Bugs found and fixed along the way:**

- Half of the templates exported code that did not compile: hex colors, missing commas, random class names starting with digits, Supabase code without a connection.
- 24 palette widgets rendered as "Unknown".
- Quotes and `$` in text broke exported code.
- Renaming a page wrote to `className`, so the rename was lost.
- Buttons ignored their action lists in preview.
- Native app labels were not renamed in exports.
- The canvas showed a fake bottom navigation bar that never appeared in the export.
- Save on a local draft reported success but saved nothing.

---

## 1. Executive summary

SynappKit already covers FlutterFlow's core loop: a visual canvas, about 90 widgets, a properties panel, a widget tree, a basic action flow, theme tokens, Supabase data binding, AI page generation, a template marketplace, and full code export.

The largest gaps fall into four layers:

1. **App logic layer:** state variables (app, page, and component), page parameters, conditional logic, conditional visibility, a broad action library, and custom code.
2. **Backend breadth:** generated-app authentication, Firebase/Firestore as a data source, a REST API builder that reaches the exported code, and file storage.
3. **Design scale:** responsive breakpoints, reusable components with parameters, animations, dark mode, localization, and Figma import.
4. **Team and shipping:** version history and branching, collaboration, a real test/run mode, and one-click deploy to the web and the app stores.

There is also **platform debt to clear first** (section 3). The app is web-only, it hard-codes secrets, it saves destructively, and its tests are broken. These issues will slow every feature listed after them.

### Parity scorecard

| Area | FlutterFlow | SynappKit | Parity |
|---|---|---|---|
| Visual UI builder | Canvas, storyboard, 200+ widgets, layers, shortcuts | Phone-frame canvas, ~90 widgets, tree, zoom, undo/redo | 🟡 ~55% |
| Design system | Theme, typography, dark mode, Figma import, design libraries | Color and text tokens, "themed widgets" | 🟡 ~40% |
| Components | Parameters, child slots, component state, libraries | Themed widgets (style presets only) | ❌ ~15% |
| State management | App / page / component state, persisted state, custom data types, enums | Preview-only `widgetStates`, controllers generated for text fields | ❌ ~10% |
| Navigation | Routes, page params, deep links, nav bar, auth-guarded routes | Push/pop, bottom-nav shell, `idParam` only | 🟡 ~35% |
| Actions & logic | 100+ actions, conditionals, loops, action blocks, custom actions | Navigate and Supabase insert/update/delete | ❌ ~10% |
| Backend: Supabase | Auth, queries, realtime, storage, RPC | Queries, filters, realtime stream, CRUD | 🟡 ~50% |
| Backend: Firebase | Auth, Firestore, Storage, Functions, FCM | Used only for SynappKit's own login | ❌ 0% |
| REST APIs | API calls, JSON paths, OpenAPI import, groups, private calls | Global API setting, not exported | ❌ ~5% |
| Custom code | Custom functions, actions, widgets, pub packages, code editor | — | ❌ 0% |
| AI | Page/component gen, AI agent, DreamFlow, theme gen, MCP | 4-provider page generation with chat history, AI palette | 🟡 ~40% |
| Testing | Test mode, run mode, local run, debug panel, automated tests | Static "Live preview" | 🟡 ~15% |
| Collaboration | Real-time multi-user, comments, branching, snapshots | — | ❌ 0% |
| Export & deploy | Code/APK download, GitHub, web hosting, app stores, VS Code, CLI | ZIP export of full project | 🟡 ~25% |
| Integrations | Payments, maps, ads, analytics, search, push, etc. | — | ❌ 0% |
| Marketplace | Templates, components, libraries, paid items | Templates with categories and admin approval | 🟡 ~50% |
| Accessibility & i18n | Semantics, localization, RTL | — | ❌ 0% |

---

## 2. Detailed feature comparison

### 2.1 Visual UI builder

| FlutterFlow feature | SynappKit status | Evidence / notes |
|---|---|---|
| Drag-and-drop canvas | ✅ | [canvas_preview_new.dart](lib/widgets/canvas_preview_new.dart) |
| Widget palette with search, categories, and recents | ✅ | [widget_side_bar.dart](lib/widgets/widget_sidebar/widget_side_bar.dart), `premium_searchbar.dart`, `recently_used_section.dart` |
| Widget tree / layers panel | ✅ | [widget_tree_editor.dart](lib/widgets/widget_tree/widget_tree_editor.dart) |
| Properties panel | ✅ | [properties_panel.dart](lib/widgets/properties_panel.dart) |
| Undo / redo | ✅ | [widget_command_manager.dart](lib/widgets/widget_context_menu/widget_command_manager.dart), Ctrl+Z/Y |
| Context menu (duplicate, wrap, delete) | ✅ | [widget_context_menu_actions.dart](lib/widgets/widget_context_menu/widget_context_menu_actions.dart) |
| Zoom | ✅ | Canvas `_zoomLevel` |
| Multiple pages | ✅ | Add, rename, duplicate, and delete screens |
| **Device size switcher** (phone, tablet, desktop, custom) | ❌ | Canvas width is hard-coded to 380 px |
| **Storyboard view** (all pages with nav arrows) | ❌ | — |
| Copy/paste widgets across pages and projects | 🟡 | Duplicate exists. No clipboard. |
| Multi-select and bulk edit | ❌ | — |
| Keyboard-shortcut set and command palette (Cmd+K) | 🟡 | Only delete and undo/redo |
| Canvas rulers, guides, and padding overlays | ❌ | — |
| Widget count | 🟡 | ~90 vs. 200+. Missing: WebView, VideoPlayer, AudioPlayer, Lottie, Rive, Charts, Calendar, Google Map, PinCode, RatingBar, Stepper widget, Countdown, Signature, Markdown, QR code, Staggered grid, Swipeable stack, Flip card, Credit-card form, Toggle icon, etc. |
| Layout-overflow warnings | ❌ | — |

### 2.2 Design system & theming

| FlutterFlow feature | Status | Notes |
|---|---|---|
| Color tokens (primary, secondary, semantic) | ✅ | `_themeProperties` in the provider, [theme_settings_screen.dart](lib/screens/theme_settings_screen.dart) |
| Typography scale | ✅ | display → body tokens |
| Theme export to `theme.dart` | ✅ | [theme_generator.dart](lib/generators/theme_generator.dart) |
| AI palette generation | 🟡 | Shown in the UI. Verify that it is wired up end to end. |
| **Dark mode** (paired light and dark tokens, `ThemeMode`) | ❌ | No `darkTheme` is generated |
| Custom fonts and icon packs upload | ❌ | Inter is bundled. Font family is a string. |
| Google Fonts picker | ❌ | — |
| Design tokens for spacing, radius, and shadows | ❌ | — |
| **Figma theme and frame import** | ❌ | — |
| Shareable design-system libraries across projects | ❌ | — |

### 2.3 Components

| FlutterFlow feature | Status | Notes |
|---|---|---|
| Reusable components | 🟡 | "Themed widgets" are style presets, not composite widget trees |
| Component parameters (typed inputs) | ❌ | — |
| Component callbacks (action parameters) | ❌ | — |
| Component state | ❌ | — |
| Child slots (named drop zones) | ❌ | — |
| Edit the master once and update every instance | ❌ | — |
| Publish components to a library or marketplace | ❌ | — |

### 2.4 State management & data types

| FlutterFlow feature | Status | Notes |
|---|---|---|
| App state (global, optionally persisted) | ❌ | `widgetStates` exists only in the editor preview |
| Page state | ❌ | The generator emits controllers for inputs only |
| Component state | ❌ | — |
| Custom data types (structs) | ❌ | — |
| Enums | ❌ | — |
| Constants and environment values (dev/prod) | ❌ | — |
| Variable binding UI ("Set from variable") on any property | 🟡 | `dataBinding` covers Supabase columns on Text and similar widgets only |
| Expressions and code-expression editor | ❌ | — |

### 2.5 Navigation & routing

| FlutterFlow feature | Status | Notes |
|---|---|---|
| Navigate to page and back | ✅ | `navigate` action, `__back__` |
| Bottom nav shell | ✅ | `generateMainNavigationScreenFile` |
| Drawer, TabBar, PageView | ✅ | Generators exist |
| **Page parameters** (typed) | 🟡 | Only a single `idParam` string |
| Named routes / `go_router` | ❌ | Generated code uses `MaterialPageRoute` |
| Deep links and URL paths for web | ❌ | — |
| Initial page and logged-in page | ❌ | — |
| Auth-guarded routes | ❌ | — |
| Transition animations | ❌ | — |

### 2.6 Actions & logic

| FlutterFlow feature | Status | Notes |
|---|---|---|
| Action flow editor | 🟡 | [action_flow_editor.dart](lib/widgets/property_editors/action_flow_editor.dart) has a linear list of 4 action types |
| Triggers (on tap, long press, double tap, on page load, on change, on submit) | 🟡 | Tap only |
| Conditional actions (if/else) | ❌ | — |
| Loops, wait, and terminate | ❌ | — |
| Update app, page, or component state | ❌ | — |
| UI actions: show snackbar, dialog, bottom sheet; toggle drawer; launch URL; copy to clipboard; haptics | ❌ | Widgets exist, but no actions trigger them |
| Form validation action | ❌ | — |
| API-call action with success/failure branches | ❌ | — |
| Auth actions (login, signup, logout, reset password) | ❌ | — |
| Device actions: camera, gallery, location, share, permissions | ❌ | — |
| Action blocks (reusable logic) | ❌ | — |
| Action output variables | ❌ | — |
| **Conditional visibility** | ❌ | — |
| Responsive visibility (hide on phone, tablet, or desktop) | ❌ | — |

### 2.7 Backend & data

| FlutterFlow feature | Status | Notes |
|---|---|---|
| Supabase connect and schema introspection | ✅ | [supabase_data_service.dart](lib/services/supabase_data_service.dart) |
| Supabase select with filters, order, and limit | ✅ | [backend_query_model.dart](lib/models/backend_query_model.dart) |
| Supabase realtime | ✅ | `.stream(primaryKey: ['id'])` in the generated service |
| Supabase insert, update, delete | ✅ | Actions |
| Supabase RPC | 🟡 | `QueryType.rpc` exists in the enum only |
| Supabase Storage upload and download | ❌ | — |
| Supabase **Auth in the generated app** | ❌ | — |
| Firebase/Firestore as a generated-app backend | ❌ | Firebase is used only for SynappKit's own login |
| Firebase Storage, Functions, FCM | ❌ | — |
| REST API calls (definition, headers, variables, JSON-path response parsing) | ❌ | `apiSettings` is stored but never generated ([api_service.dart](lib/services/api_service.dart)) |
| API groups, OpenAPI/Swagger import | ❌ | — |
| Private API calls via a cloud proxy | ❌ | — |
| Pagination and infinite scroll | ❌ | — |
| Offline-first / local DB (SQLite) | ❌ | — |
| Bind data to lists ("generate children from variable") | ✅ | ListView, GridView, Row, Column repeat in [widget_generator_registry.dart](lib/generators/widget_generator_registry.dart) |

### 2.8 Custom code

| FlutterFlow feature | Status |
|---|---|
| Custom functions (pure Dart) | ❌ |
| Custom actions (async Dart) | ❌ |
| Custom widgets (with preview) | ❌ |
| Add pub.dev dependencies | ❌ |
| In-browser code editor with analysis | ❌ |
| Custom files (`main.dart` edits, initial actions) | ❌ |

### 2.9 AI

| FlutterFlow feature | Status | Notes |
|---|---|---|
| AI page generation from a prompt | ✅ | 4 providers, retries, and conversation context ([ai_panel.dart](lib/widgets/ai_panel.dart)) |
| AI edits of the current page (diff and refine) | 🟡 | `currentJson` is sent, but the whole tree is replaced |
| AI component generation | ❌ | — |
| AI theme generation | 🟡 | "AI Palette" entry |
| Screenshot or image to UI | ❌ | — |
| AI agent: multi-step build of pages, logic, and data | ❌ | — |
| AI code generation for custom code | ❌ | — |
| MCP server so external agents (Claude Code and others) can edit projects | ❌ | — |
| Server-side key management and credits/quotas | ❌ | Keys are stored per user in Firestore and called from the browser |
| Claude as a provider | ❌ | Only OpenAI, DeepSeek, Kimi, and Gemini |

### 2.10 Testing & preview

| FlutterFlow feature | Status | Notes |
|---|---|---|
| Static preview | ✅ | [project_preview_screen.dart](lib/screens/project_preview_screen.dart) |
| Interactive preview with navigation between screens | 🟡 | Live mode exists. Verify the navigation flow. |
| **Test mode / Run mode** (a real compiled app on a shareable URL) | ❌ | — |
| Local run on device or emulator | ❌ | — |
| Debug panel (inspect state and variables) | ❌ | — |
| Automated tests | ❌ | — |
| Generated-code compile check before export | ❌ | — |

### 2.11 Collaboration & versioning

| FlutterFlow feature | Status |
|---|---|
| Teams and member invites | ❌ |
| Real-time multi-user editing | ❌ |
| Comments on widgets and pages, with task assignment | ❌ |
| Snapshots / version history and restore | ❌ |
| Branching and merging | ❌ |
| Roles and permissions | 🟡 Admin by email pattern only |
| Activity log | ❌ |

### 2.12 Export & deployment

| FlutterFlow feature | Status | Notes |
|---|---|---|
| Full code download (ZIP) | ✅ | `_downloadProjectAsZip` in [builder_screen.dart](lib/screens/builder_screen.dart) |
| Per-file code view and copy | ✅ | |
| App name, bundle ID, version, and platforms | ✅ | [app_settings_screen.dart](lib/screens/app_settings_screen.dart) |
| App icon and splash generation | ❌ | — |
| APK / IPA build | ❌ | — |
| One-click web publish and custom domain | ❌ | — |
| One-click App Store / Play Store deploy | ❌ | — |
| GitHub push / sync | ❌ | — |
| VS Code extension and CLI | ❌ | — |
| Project API (YAML read/write) | ❌ | — |
| Clean architecture in exported code (models, pages, components, backend folders) | 🟡 | Flat `lib/`, one file per screen |

### 2.13 Integrations (generated app)

| FlutterFlow feature | Status |
|---|---|
| Payments (Stripe, RevenueCat, Razorpay, Braintree) | ❌ |
| Google Maps and geolocation | ❌ |
| Push notifications (FCM / OneSignal) | ❌ |
| Analytics (Firebase, Mixpanel, Amplitude) | ❌ |
| Ads (AdMob) | ❌ |
| Search (Algolia) | ❌ |
| Media (video, audio, Lottie, Rive) | ❌ |
| In-app purchases | ❌ |
| OpenAI/Claude in the generated app | ❌ |

### 2.14 Accessibility, localization, responsiveness

| FlutterFlow feature | Status |
|---|---|
| Responsive breakpoints and per-breakpoint values | ❌ |
| Localization (multiple languages, translate-all) | ❌ |
| RTL support | ❌ |
| Semantic labels | ❌ |

### 2.15 Marketplace & platform

| FlutterFlow feature | Status | Notes |
|---|---|---|
| Template gallery with categories | ✅ | [templates_screen.dart](lib/screens/templates_screen.dart), `categories` table |
| Submit a template, with admin review | ✅ | [submissions_screen.dart](lib/screens/submissions_screen.dart) |
| Component and library marketplace | ❌ | — |
| Paid items and creator payouts | 🟡 | `is_premium` flag only |
| Plans, billing, and usage limits | ❌ | — |
| Onboarding, docs, in-app tutorials | ❌ | — |

---

## 3. Platform debt to fix first (Phase 0)

These issues are not FlutterFlow features, but they block or put at risk the features that come after them.

| ID | Task | Why | Effort |
|---|---|---|---|
| **P0-01** | Move the Supabase URL and anon key out of [main.dart](lib/main.dart) into `--dart-define` or an env config | The keys are in git history, and every environment uses the same project | S |
| **P0-02** | Stop persisting `serviceRoleKey` to localStorage and the `__settings__` row. Use the user's own OAuth or PAT through an Edge Function | A leaked service-role key gives full access to the user's database | M |
| **P0-03** | Proxy AI calls through a Supabase Edge Function. Keep keys server-side and enforce quotas | Calls from the browser expose keys. Usage can't be metered. | M |
| **P0-04** | Replace delete-then-insert in `saveProjectToSupabase()` with an upsert by screen ID plus a deletion diff, or with a single RPC transaction | A save that fails halfway can lose screens | S |
| **P0-05** | Remove `dart:html` (use `package:web` behind conditional imports) | Unblocks VM tests and desktop builds | S |
| **P0-06** | Fix the test suite: delete the default counter test, run `--platform chrome` in CI, and add golden tests for generators | Generator regressions currently go unnoticed | M |
| **P0-07** | Add a CI job that exports every template and runs `flutter analyze` on the exported code | Guarantees that exported code compiles, which is a core promise of FlutterFlow | M |
| **P0-08** | Version the project JSON schema (`schemaVersion`) and add migrations | Every later task changes the node schema | S |
| **P0-09** | Replace mutable static generator state with a `GenerationContext` object that is passed through generators | Required for components, state, and concurrent generation | M |
| **P0-10** | Move admin checks from email patterns to a `roles` table or a custom JWT claim | Security and maintainability | S |
| **P0-11** | Delete dead code: `old-canvas_preview.dart`, `dummygenerate.dart`, `generatedjsonbykimi`, the duplicate scaffold generator, `analysis*.txt` | Reduces confusion | S |
| **P0-12** | Restructure the exported project into folders: `pages/`, `components/`, `backend/`, `app_state.dart`, `flutter_flow`-style utils | Groundwork for state, components, and custom code | M |

---

## 4. Feature task backlog (prioritized)

Each task lists its acceptance criteria (AC) and its main touchpoints. Read "canvas + generator" as both pipelines described in [CLAUDE.md](CLAUDE.md).

### Phase 1: Logic foundations (P1, highest value)

#### F1-01 · State variables (app, page, component). **L**
- Data model: `StateVariable { name, type (String/int/double/bool/Color/DateTime/List/DataType), defaultValue, persisted }`, with `appState` stored on the project and `pageState` on each screen root.
- UI: a "State" tab in the left sidebar with add, edit, and delete.
- Generator: `app_state.dart` (`ChangeNotifier`, `shared_preferences` for persisted values), and page state as `State` fields.
- Canvas: the preview runtime resolves values from the editor's `widgetStates`.
- **AC:** A Text bound to `appState.counter` shows its live value. A button's "Update state +1" action works in the preview and in the exported app.
- Touchpoints: `widget_tree_provider.dart`, `project_generator.dart`, `base_widget_generator.dart`, a new `state_panel.dart`.

#### F1-02 · Universal value binding ("Set from variable"). **L**
- Every property editor gets a binding toggle. Sources: literal, app state, page state, page parameter, query row/column, widget state (input value), or expression.
- Store bindings as `{"$bind": {"source": "...", "path": "..."}}` in properties. Add a resolver in `base_widget_builder.dart` and a code emitter in `base_widget_generator.dart`.
- **AC:** Color, text, visibility, and image URL can all be bound. The exported code references the right variable.

#### F1-03 · Conditional visibility & responsive visibility. **M**
- `properties.visibility = { condition: <binding expr>, hideOn: ['phone','tablet','desktop'] }`.
- **AC:** The widget is hidden on the canvas when the condition is false, and the exported code wraps it in `if (...)` or `Visibility`.

#### F1-04 · Action library expansion and an action-flow editor v2. **L**
- Triggers: onTap, onLongPress, onDoubleTap, onPageLoad, onChanged, onSubmit.
- Actions: update state, show snackbar, show dialog or bottom sheet, toggle drawer, launch URL, copy to clipboard, haptic, wait, validate form, refresh query, API call, auth actions, upload file.
- Control flow: if/else (conditions built from bindings), terminate, and action output variables.
- Move from a flat list to a tree-based editor with a node-graph style UI.
- **AC:** A login flow (validate → auth sign-in → if success navigate, else snackbar) can be built with no code and exported.
- Touchpoints: `action_flow_editor.dart`, `generateActionFlowCode` in `base_widget_generator.dart`.

#### F1-05 · Typed page parameters. **M**
- Each page declares parameters (`name`, `type`, `required`), and the navigate action passes values from bindings.
- Replaces the hard-coded `idParam`.
- **AC:** A product list navigates to a product detail page with `productId:int` and the detail query filters on it.

#### F1-06 · Custom data types and enums. **M**
- A project-level schema editor. The generator emits `lib/backend/schema/structs/*.dart` with `fromJson`/`toJson`.
- **AC:** An app-state variable of type `List<CartItem>` works end to end.

### Phase 2: Backend breadth (P1)

#### F2-01 · REST API builder. **L**
- API call definitions: method, URL with `[variables]`, headers, body (JSON, form, multipart), and auth. The "Test" tab shows the response, and JSON-path pickers create response fields.
- API groups with a shared base URL and headers. Import from cURL and OpenAPI/Swagger.
- Generator: `lib/backend/api_requests/api_calls.dart` using `http`.
- Bind API results to lists and text (through F1-02), and add an API-call action with success/failure branches.
- **AC:** A JSONPlaceholder `/posts` call is bound to a ListView, and the exported app fetches the data.
- Replaces the unused `apiSettings` and `api_service.dart`.

#### F2-02 · Generated-app authentication. **L**
- Providers: Supabase Auth (email, magic link, Google, Apple) first, then Firebase Auth.
- Project setting for the auth provider, the initial (logged-out) page, and the logged-in page. Add a `currentUser` binding source and auth actions.
- **AC:** The exported app has working sign-up, login, and logout, plus a route guard.

#### F2-03 · Supabase completion. **M**
- RPC calls (`QueryType.rpc`), Storage upload and download (upload action plus a `media` binding), pagination with infinite scroll on ListView, and query parameters from bindings (not only `activeRowData`).
- **AC:** A user can upload an avatar to a bucket and display it, and a paged list loads 20 rows at a time.

#### F2-04 · Firebase backend option. **XL**
- Firestore collection schema editor, queries (filters, order, limit, single document), CRUD actions, Storage, and generated `firebase_options` setup instructions.
- **AC:** The same todo template runs with Firestore selected as the backend.

#### F2-05 · Environment values (dev/staging/prod). **S**
- Per-environment constants (API base URL, keys), emitted as `--dart-define` or an `environment.dart`.

### Phase 3: Design at scale (P2)

#### F3-01 · Real components. **XL**
- A component is a named `WidgetNode` tree with typed parameters, callback parameters, its own component state, and child slots.
- An instance node has `type: 'Component', componentId, args`. Editing the master updates every instance.
- Generator: `lib/components/<name>_widget.dart`.
- Migrate the existing "themed widgets" into components.
- **AC:** A `ProductCard(title, price, onAddToCart)` component is used in three places. A change to its color updates all three.

#### F3-02 · Responsive design. **L**
- Canvas device switcher (phone, tablet, desktop, custom width) and breakpoint-specific property overrides.
- Generator emits `MediaQuery`-based helpers.
- **AC:** A grid shows 2 columns on phone and 4 on desktop, both on the canvas and in exported web builds.

#### F3-03 · Dark mode. **M**
- Paired light and dark token values, a canvas theme toggle, and generated `darkTheme` with `ThemeMode` (plus a "toggle theme" action).

#### F3-04 · Animations. **M**
- Per-widget animations (fade, slide, scale, rotate, shimmer), with triggers on page load, on action, or on scroll.
- Page transition types on the navigate action.
- Generator: `flutter_animate`-style chains, or explicit `AnimationController`s.

#### F3-05 · Custom fonts, Google Fonts & icon packs. **S**
- A Google Fonts picker (`google_fonts` package in the export), custom font upload, and icon-pack selection.

#### F3-06 · Spacing, radius, and shadow tokens. **S**

#### F3-07 · Figma import. **XL**
- Import a theme (colors and text styles) from the Figma REST API first, then frames converted to `WidgetNode` (auto-layout to Row/Column).

#### F3-08 · Canvas UX upgrades. **M** (each can ship separately)
- Storyboard view, clipboard copy/paste across pages and projects, multi-select, a Cmd+K command palette, a shortcut cheat sheet, overflow warnings, and rulers and spacing overlays.

#### F3-09 · Widget library expansion. **L** (ongoing)
- Priority order: WebView, VideoPlayer, Lottie, Charts (`fl_chart`), Google Map, PinCode, RatingBar, Calendar, Markdown, Stepper, Staggered grid, Countdown timer, Signature, QR code, Audio player, Rive, Swipeable stack, Flip card.
- Follow the 6-step checklist in [CLAUDE.md](CLAUDE.md#adding-or-changing-a-widget-type) for each widget.

### Phase 4: Custom code (P2)

#### F4-01 · Custom functions, actions, and widgets. **XL**
- An in-browser Dart editor (`code_text_field` or an embedded Monaco) with typed arguments and return values declared in a sidebar.
- Custom widgets get width/height parameters and a canvas placeholder; real compilation comes later.
- Exported to `lib/custom_code/{actions,widgets}/` and `lib/flutter_flow/custom_functions.dart`.
- **AC:** A custom function `formatPrice(double)` is used in a Text binding. A custom action is called from the action flow.

#### F4-02 · pub.dev dependency manager. **S**
- Add packages and versions that are merged into the generated `pubspec.yaml`.

#### F4-03 · Compile-check service. **L**
- A server-side container that runs `flutter analyze` on the export and surfaces errors in the editor.
- Also the backbone of F6-01.

### Phase 5: AI upgrades (P2)

#### F5-01 · Incremental AI edits. **M**
- The AI returns a JSON patch for the selected subtree instead of a whole-page replacement. Show a diff preview with accept and reject.

#### F5-02 · Image or screenshot to UI. **M**
- Send an uploaded screenshot to a vision-capable model and receive a `WidgetNode` tree.

#### F5-03 · AI agent mode. **L**
- A multi-step agent with tools such as `addPage`, `addWidget`, `setProperty`, `createQuery`, `addAction`, and `createStateVar`. It plans, executes, and shows a step log, and it is undoable as one transaction.

#### F5-04 · AI component, theme, and custom-code generation. **M**

#### F5-05 · MCP server for SynappKit projects. **L**
- Expose the project's tree, theme, queries, and actions as MCP tools so that external agents such as Claude Code can build in a project. This matches FlutterFlow MCP (Apr 2026).

#### F5-06 · Add Claude as a provider. **S**
- Add an Anthropic provider (for example `claude-sonnet-5-5`) next to OpenAI, DeepSeek, Kimi, and Gemini in [ai_generation_service.dart](lib/services/ai_generation_service.dart). Route it through the P0-03 proxy.

### Phase 6: Test, run & ship (P2)

#### F6-01 · Run mode (a real compiled web build). **L**
- A build worker compiles the exported project with `flutter build web` and serves it on a shareable preview URL, with hot-refresh on save.

#### F6-02 · Interactive test mode in the editor. **M**
- Upgrade the live preview into a full runtime interpreter: navigation, state, actions, and live queries, plus a **debug panel** that shows state variables and query results.

#### F6-03 · GitHub integration. **M**
- Connect a repository and push the export to a `synappkit` branch on each publish.

#### F6-04 · Web hosting & custom domains. **L**
- Publish F6-01 builds to `<project>.synappkit.app` and support custom-domain CNAMEs.

#### F6-05 · App icon, splash & store assets. **S**
- Upload a 1024 px icon, then generate `flutter_launcher_icons` and `flutter_native_splash` configs in the export.

#### F6-06 · APK / IPA build & store deploy. **XL**
- Cloud builds through Codemagic or a self-hosted runner, with fastlane upload to Play and TestFlight.

#### F6-07 · Generated-code quality. **M**
- Folder structure (P0-12), `go_router`, page models, and dispose hygiene.
- Golden tests for each generator, so that the export reads like code a human wrote. FlutterFlow's export is often criticized on this point.

### Phase 7: Collaboration & versioning (P3)

#### F7-01 · Version history / snapshots. **M**
- A `project_versions` table that auto-snapshots on save, with restore and compare actions.

#### F7-02 · Teams & roles. **M**
- `teams`, `team_members(role: owner/editor/viewer)`, project sharing, and RLS updates.

#### F7-03 · Comments on widgets and pages. **M**
- Comments anchored to a `WidgetNode` ID, with mentions and resolve.

#### F7-04 · Real-time collaboration. **XL**
- Supabase Realtime presence (cursors, selection), with operation-based syncing of tree edits (CRDT or server-ordered ops).

#### F7-05 · Branching & merge. **XL**
- Builds on F7-01 and needs a tree-diff/merge algorithm.

### Phase 8: Integrations (P3, pick based on user demand)

| ID | Integration | Effort |
|---|---|---|
| F8-01 | Push notifications (FCM / OneSignal) with a send-push action | L |
| F8-02 | Stripe / RevenueCat payments | L |
| F8-03 | Google Maps widget, plus geolocation and a "get current location" action | M |
| F8-04 | Analytics events (Firebase / Mixpanel), auto-logging page views | S |
| F8-05 | AdMob banner and interstitial | S |
| F8-06 | Algolia search | M |
| F8-07 | Media pickers (camera, gallery, file), with permission handling | M |
| F8-08 | Share, launch URL, local notifications, and haptics device actions | S |
| F8-09 | Offline-first local DB (SQLite/drift or PowerSync with Supabase) | XL |

### Phase 9: Accessibility, i18n & business (P3)

| ID | Task | Effort |
|---|---|---|
| F9-01 | Localization: a project language list, translatable strings on Text and labels, AI "translate all", and generated `intl`/ARB files | L |
| F9-02 | RTL preview and generation | S |
| F9-03 | Semantic labels on widgets, and an accessibility lint in the editor | S |
| F9-04 | Plans, billing (Stripe), usage limits on projects, AI requests, and export (mirrors the FlutterFlow Free/Basic/Growth/Business tiers) | L |
| F9-05 | Component and library marketplace (extends templates), creator payouts | L |
| F9-06 | Onboarding tour, in-app docs, and keyboard-shortcut help | M |

---

## 5. Suggested roadmap

| Quarter | Focus | Tasks |
|---|---|---|
| **Now (4–6 weeks)** | Hardening | P0-01 … P0-12, F5-06 |
| **Next (Q1)** | "Real apps, not mockups" | F1-01, F1-02, F1-03, F1-04, F1-05, F2-01, F2-02 |
| **Q2** | Scale & reuse | F3-01, F3-02, F3-03, F2-03, F1-06, F6-02, F7-01 |
| **Q3** | Ship & extend | F4-01, F4-03, F6-01, F6-03, F6-05, F5-01, F5-03, F3-09 |
| **Q4+** | Teams & ecosystem | F7-02 … F7-05, F6-04, F6-06, F8-x, F9-x, F2-04, F3-07 |

### Differentiation opportunities

SynappKit doesn't need to copy FlutterFlow everywhere. These are areas where it can lead:

- **Clean, human-readable export.** FlutterFlow's generated code is widely seen as verbose. A small, idiomatic export (golden-tested, F6-07) is a selling point.
- **Supabase-first.** FlutterFlow is Firebase-first. Deep Supabase support (RLS-aware queries, Edge Functions, Storage, Auth) is a niche SynappKit can own.
- **Bring-your-own AI model**, with an MCP server (F5-05) so that developers can build with Claude Code or other agents directly.
- **Open template marketplace** with creator revenue (F9-05).

---

## 6. Sources

- [FlutterFlow home](https://www.flutterflow.io/)
- [FlutterFlow docs](https://docs.flutterflow.io/)
- [FlutterFlow pricing & plan comparison](https://www.flutterflow.io/pricing)
- [FlutterFlow community announcements](https://community.flutterflow.io/announcements) (FlutterFlow MCP, Apr 2026; Child Slots v6.6.56)
- [FlutterFlow changelog: GenUI & page/component gen](https://www.flutterflow.io/changelog/genui-page-component-gen-updates)
