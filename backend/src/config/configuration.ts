const normaliseOrigin = (origin: string) => origin.trim().replace(/\/+$/, '');

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

const configuration = () => ({
  port: parseInt(process.env.PORT ?? '3000', 10),
  isProduction: process.env.NODE_ENV === 'production',
  cors: corsConfig(),
  jwt: {
    secret: process.env.JWT_SECRET,
    expiresIn: process.env.JWT_EXPIRES_IN ?? '1d',
  },
});

export type AppConfig = ReturnType<typeof configuration>;

export default configuration;
