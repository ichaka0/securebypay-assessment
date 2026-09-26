/**
 * Typed, structured view over process.env.
 * Access values via `ConfigService.get('db.host')` etc.
 */
const configuration = () => ({
  port: parseInt(process.env.PORT ?? '3000', 10),
  corsOrigin: process.env.CORS_ORIGIN ?? '*',
  // Database options live in src/database/data-source.ts so the TypeORM CLI
  // and the running app share one definition.
  jwt: {
    secret: process.env.JWT_SECRET,
    expiresIn: process.env.JWT_EXPIRES_IN ?? '1d',
  },
});

export type AppConfig = ReturnType<typeof configuration>;

export default configuration;
