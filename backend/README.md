# Myafrimall API (NestJS)

REST API for authentication, the dashboard, shipments and the wallet. Stack: NestJS 11,
TypeORM, PostgreSQL, JWT (Passport), class-validator, Swagger.

## Setup
```bash
cp .env.example .env     # fill in DB credentials and JWT_SECRET
npm install
npm run start:dev        # http://localhost:3000/api — migrations run on boot
```
Interactive docs: **http://localhost:3000/docs**

| Variable | Default | Notes |
|---|---|---|
| `PORT` | `3000` | |
| `CORS_ORIGIN` | `*` | Comma-separated list of origins in production |
| `DB_HOST` / `DB_PORT` | `localhost` / `5432` | |
| `DB_USERNAME` / `DB_PASSWORD` / `DB_NAME` | required | |
| `DB_SSL` | `false` | |
| `JWT_SECRET` | required (16+ chars) | `openssl rand -hex 32` |
| `JWT_EXPIRES_IN` | `1d` | |

The app validates its environment at boot with Joi and refuses to start if any variable is invalid.

## Endpoints (prefix `/api`)
| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/auth/register` | – | Create an account → `{ accessToken, expiresIn, user }`. 409 if the email is taken. |
| POST | `/auth/login` | – | → `{ accessToken, expiresIn, user }`. 401 with a generic message on bad credentials. |
| GET | `/auth/me` | JWT | Current user |
| GET | `/dashboard/overview?period=week\|month\|year` | JWT | Wallet balance and shipment/export/import counts with % change against the previous period |
| GET | `/dashboard/growth?range=year\|month\|week` | JWT | Shipment value per bucket (12 months / 30 days / 7 days), zero-filled |
| GET | `/dashboard/banners` | JWT | Carousel slides |
| GET | `/shipments?page=&limit=` | JWT | Newest-first paginated shipments |
| POST | `/shipments/:id/pay` | JWT | Pay from the wallet. 400 if the balance is too low, 409 if already paid. |
| POST | `/wallet/fund` | JWT | `{ amount }` (₦100 – ₦10,000,000), simulated top-up |
| GET | `/health` | – | Liveness and DB check |

### Error format
Every error returns the same shape, so the client can show `message` in a toast and `errors`
next to the matching fields:
```json
{
  "statusCode": 400,
  "error": "BAD_REQUEST",
  "message": "Enter a valid email address",
  "errors": { "email": ["Enter a valid email address"] },
  "path": "/api/auth/register",
  "timestamp": "2026-09-26T10:00:00.000Z"
}
```

## Structure
```
src/
  main.ts / app.setup.ts   bootstrap, global prefix, helmet, CORS, ValidationPipe, error filter, Swagger
  config/                  typed config + Joi env validation
  database/                shared DataSource (app + CLI) and migrations
  common/                  base entity, exception filter, validation formatter, decorators, transformers
  auth/                    register/login/me, JWT strategy + guard, DTOs
  users/                   User entity + persistence
  shipments/               Shipment entity, listing, pay (transactional), demo seed
  dashboard/               overview stats, growth series, banners
  wallet/                  fund wallet
  health/                  health check
```

## Security
- Passwords hashed with bcrypt (12 rounds). Hashes are never selected by default and never serialised.
- Login always runs a bcrypt compare, even for unknown emails, so response timing doesn't reveal which emails exist.
- Global rate limit of 100 requests/min per IP; auth routes are limited to 10/min.
- `ValidationPipe` with `whitelist` + `forbidNonWhitelisted` rejects unexpected fields. `helmet` sets security headers.
- Wallet debits run in a transaction with `SELECT … FOR UPDATE` on both the shipment and the user rows, which prevents double payment and overdrawing.
- A duplicate email caught by the unique index during a concurrent sign-up is also mapped to 409.

## Scripts
```bash
npm run start:dev          # watch mode
npm run build && npm run start:prod
npm run lint
npm test                   # unit tests
npm run test:e2e           # full flow against the DB in .env
npm run migration:run      # apply migrations manually
npm run migration:generate --name=AddSomething
```
