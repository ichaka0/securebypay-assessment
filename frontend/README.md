# Myafrimall Web (Flutter)

Flutter Web client for the Sign up, Sign in and Dashboard screens.

## Run
```bash
flutter pub get
flutter run -d chrome --web-port 8080 \
  --dart-define=API_BASE_URL=http://localhost:3000/api
```
`API_BASE_URL` defaults to `http://localhost:3000/api`.

Release build: `flutter build web --release --dart-define=API_BASE_URL=https://<host>/api`

## Architecture
Feature-first layout with a thin data → application → presentation split:

```
lib/
  main.dart, app.dart          ProviderScope, MaterialApp.router, path URL strategy
  core/
    config/                    compile-time config (API_BASE_URL)
    theme/                     colour, type and radius tokens (single source for Figma values)
    responsive/                breakpoints + context helpers
    network/                   Dio ApiClient (bearer token, 401 hook) + ApiException
    storage/                   token persistence
    router/                    go_router with an auth redirect guard
    utils/                     validators (mirror the backend DTOs) and formatters
    widgets/                   text fields, password/phone fields, button, snackbar,
                               dotted world map painter, country flags
  features/
    auth/                      repository, AuthController (session), Sign up / Sign in pages
    dashboard/                 repository, providers, dashboard page + section widgets
```

State management uses Riverpod:
- `AuthController` holds the session.
- `FutureProvider`s serve the dashboard data. The period dropdown and chart toggle are plain
  `StateProvider`s, and changing one refetches the data that depends on it.
- `RecentShipmentsController` handles pagination and Pay Now. Wallet balance updates are
  published through `walletBalanceProvider`, so the balance card updates without reloading
  the Overview row.

## Design assets
All colours and sizes live in `lib/core/theme/`. Bitmap artwork is optional. Drop the Figma
exports into `assets/images/` with these names and they replace the built-in fallbacks:

| File | Used for | Fallback |
|---|---|---|
| `banner_globe_boxes.png` | Dashboard banner illustration | Icon composition |
| `avatar.png` | Sidebar/app bar avatar | User initials |

The dotted world map (`assets/data/world_map_dots.json`) was generated with the
[`dotted-map`](https://www.npmjs.com/package/dotted-map) npm package. The Inter font is
bundled under the SIL Open Font License (`assets/fonts/`).

## Tests
```bash
flutter analyze
flutter test
```
- `test/core/validators_test.dart`: form rules.
- `test/features/auth/`: both auth screens at 390/768/1440px, empty-form validation, the
  server 401 message shown to the user, and the password visibility toggle.
- `test/features/dashboard/`: the dashboard at 390/768/1440px against a fake API. Fails on
  any layout overflow.
