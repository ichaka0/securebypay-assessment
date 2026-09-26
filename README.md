# Myafrimall — MashonaDev Technical Test

A responsive Flutter Web app backed by a NestJS API and PostgreSQL. It implements the three
screens from the Figma file (**Sign up**, **Sign in**, **Dashboard**). Registration, login and
every interactive element on the dashboard work end to end.

```
.
├── backend/    NestJS 11 · TypeORM · PostgreSQL · JWT
└── frontend/   Flutter 3.22 (Web) · Riverpod · go_router · Dio · fl_chart
```

## Quick start

### Prerequisites
- Node.js 20+ and npm
- PostgreSQL 14+ running locally
- Flutter 3.22+ with Chrome

### 1. Database
```bash
createdb myshipment          # or: psql -U postgres -c 'CREATE DATABASE myshipment;'
```

### 2. Backend (http://localhost:3000)
```bash
cd backend
cp .env.example .env         # set DB_USERNAME / DB_PASSWORD / JWT_SECRET
npm install
npm run start:dev            # applies migrations on boot
```
Swagger UI: http://localhost:3000/docs

### 3. Frontend (http://localhost:8080)
```bash
cd frontend
flutter pub get
flutter run -d chrome --web-port 8080 \
  --dart-define=API_BASE_URL=http://localhost:3000/api
```

Create an account on the Sign up screen. The new account comes with demo shipments, so the
dashboard, chart and stats have data straight away.

## What's implemented

| Area | Behaviour |
|---|---|
| **Sign up** | Inline validation that mirrors the server rules: required names, email format, Nigerian phone (`+234`), password of 8+ characters with a letter and a digit. Server errors (e.g. *409 email already exists*) appear under the matching field and in a toast. On success the user is signed in and taken to the dashboard. |
| **Sign in** | Email/password with a show/hide toggle. Wrong credentials always return a generic *Invalid email or password*. The endpoint is rate limited. |
| **Session** | JWT stored in `localStorage` and restored on reload. The route guard sends signed-out users to Sign in. If a call returns 401 (expired token), the user is logged out. |
| **Dashboard** | Promo banner carousel (auto-advancing, with dots). Overview with the wallet balance and total shipments/exports/imports, each with the % change against the previous period. A period dropdown (week/month/year) re-queries the API. |
| **Fund Wallet** | Dialog with validated amount input and quick-amount chips. Credits the wallet via the API (payment is simulated). |
| **Company Growth** | Line chart of shipment value per bucket, with a Year/Month/Week toggle that queries the API. |
| **Recent shipment** | Expandable cards. **View More** opens a details dialog. **Pay Now** pays from the wallet: row-locked, and blocked with a clear error when the balance is too low. **See All** loads more pages. |
| **Navigation** | Fixed sidebar on desktop, drawer below 1024px. Logout. Menu items without a screen in the design show a "coming soon" toast. |

### Responsive breakpoints
| Width | Auth screens | Dashboard |
|---|---|---|
| ≥ 1024 (desktop) | Split 48/52 form + world-map panel, as in Figma | Sidebar; overview in one row |
| 600–1023 (tablet) | Map panel becomes a banner above the form | Drawer; balance above a row of 3 stats |
| < 600 (mobile) | Form only, full-width button | Drawer; stats in a 2-column grid; cards reflow to a 2-column field grid |

Widget tests render every screen at 390, 768 and 1440px and fail on any layout overflow.

## Testing
```bash
cd backend  && npm run lint && npm test && npm run test:e2e   # e2e needs the DB from .env
cd frontend && flutter analyze && flutter test
```

## Design notes and trade-offs
- **Figma fidelity.** Colours, type scale and radii are centralised in
  `frontend/lib/core/theme/`, so matching Figma exactly is a token change there. Bitmap
  artwork (banner illustration, avatar) loads from `frontend/assets/images/`; each has a
  code-drawn fallback until the Figma exports are added (see `frontend/README.md`).
- **Dotted world map.** Generated from real geography with the `dotted-map` package and
  shipped as ~4.7k points (30 KB JSON). A `CustomPainter` draws it in one call, which stays
  sharp at any size and is much lighter than the ~1 MB SVG equivalent.
- **Token storage.** The JWT sits in `localStorage` for simplicity. A production build would
  use an httpOnly refresh-token cookie with a short-lived in-memory access token.
- **Demo data.** Seeding shipments at sign-up keeps the review flow to a single step. In a
  real product, shipments would come from a booking flow.
