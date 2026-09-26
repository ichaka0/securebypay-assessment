/** Origins arrive without a trailing slash, so normalise configured values. */
const normaliseOrigin = (origin: string) => origin.trim().replace(/\/+$/, '');

/**
 * Browser origins allowed to call the API: the deployed frontend
 * (`FRONTEND_URL`) plus any extra `CORS_ORIGIN` entries.
 * `*`, or no origins at all outside production, allows every origin.
 */
const corsConfig = () => {
  const origins = [
    process.env.FRONTEND_URL ?? '',
    ...(process.env.CORS_ORIGIN ?? '').split(','),
  ]
    .map(normaliseOrigin)
    .filter(Boolean);

  const allowAll =
    origins.includes('*') ||
    (origins.length === 0 && process.env.NODE_ENV !== 'production');

  return { allowAll, origins: origins.filter((o) => o !== '*') };
};

/**
 * Typed, structured view over process.env.
 * Access values via `ConfigService.get('jwt.secret')` etc.
 */
const configuration = () => ({
  port: parseInt(process.env.PORT ?? '3000', 10),
  isProduction: process.env.NODE_ENV === 'production',
  cors: corsConfig(),
  // Database options live in src/database/data-source.ts so the TypeORM CLI
  // and the running app share one definition.
  jwt: {
    secret: process.env.JWT_SECRET,
    expiresIn: process.env.JWT_EXPIRES_IN ?? '1d',
  },
});

export type AppConfig = ReturnType<typeof configuration>;

export default configuration;
