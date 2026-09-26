import 'dotenv/config';
import { join } from 'path';
import { DataSource, DataSourceOptions } from 'typeorm';

/** `ts` under ts-node/jest, `js` in the compiled build (skips `.d.ts`). */
const EXT = __filename.endsWith('.ts') ? 'ts' : 'js';


const connectionOptions = () => {
  const url = process.env.DATABASE_URL?.trim();
  if (url) {
    
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

export const buildDataSourceOptions = (): DataSourceOptions => ({
  type: 'postgres',
  ...connectionOptions(),

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

export default new DataSource(buildDataSourceOptions());
