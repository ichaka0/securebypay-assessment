import 'dotenv/config';
import { join } from 'path';
import { DataSource, DataSourceOptions } from 'typeorm';

/** `ts` under ts-node/jest, `js` in the compiled build (skips `.d.ts`). */
const EXT = __filename.endsWith('.ts') ? 'ts' : 'js';

/**
 * Connection settings, chosen from the environment:
 *
 * * `DATABASE_URL` set (hosted Postgres such as Neon): connect with the URL.
 *   SSL settings come from the URL itself (`?sslmode=require`), and SSL is
 *   switched on by default for remote hosts.
 * * Otherwise (local Postgres): use `DB_HOST`, `DB_PORT`, `DB_USERNAME`,
 *   `DB_PASSWORD`, `DB_NAME` and `DB_SSL`.
 */
const connectionOptions = () => {
  const url = process.env.DATABASE_URL?.trim();
  if (url) {
    // An explicit `sslmode` in the URL wins (pg parses it); otherwise
    // require SSL, as managed providers do not accept plain connections.
    const sslInUrl = /[?&]sslmode=/.test(url);
    return {
      url,
      ...(sslInUrl ? {} : { ssl: { rejectUnauthorized: true } }),
    };
  }

  return {
    host: process.env.DB_HOST ?? 'localhost',
    port: parseInt(process.env.DB_PORT ?? '5432', 10),
    username: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD ?? '',
    database: process.env.DB_NAME,
    ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
  };
};

/**
 * Single source of truth for TypeORM connection options.
 * Used both by the Nest TypeOrmModule and by the TypeORM CLI (migrations).
 */
export const buildDataSourceOptions = (): DataSourceOptions => ({
  type: 'postgres',
  ...connectionOptions(),
  // Serverless Postgres (Neon) can take a few seconds to wake an idle
  // compute, so allow more than pg's default connect time.
  connectTimeoutMS: 15_000,
  extra: {
    max: parseInt(process.env.DB_POOL_MAX ?? '10', 10),
    idleTimeoutMillis: 30_000,
  },
  entities: [join(__dirname, '..', '**', `*.entity.${EXT}`)],
  migrations: [join(__dirname, 'migrations', `*.${EXT}`)],
  synchronize: false,
  migrationsRun: false,
});

/** DataSource instance consumed by `typeorm` CLI (see package.json scripts). */
export default new DataSource(buildDataSourceOptions());
