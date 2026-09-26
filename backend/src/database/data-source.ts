import 'dotenv/config';
import { join } from 'path';
import { DataSource, DataSourceOptions } from 'typeorm';

/** `ts` under ts-node/jest, `js` in the compiled build (skips `.d.ts`). */
const EXT = __filename.endsWith('.ts') ? 'ts' : 'js';

/**
 * Single source of truth for TypeORM connection options.
 * Used both by the Nest TypeOrmModule and by the TypeORM CLI (migrations).
 */
export const buildDataSourceOptions = (): DataSourceOptions => ({
  type: 'postgres',
  host: process.env.DB_HOST ?? 'localhost',
  port: parseInt(process.env.DB_PORT ?? '5432', 10),
  username: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD ?? '',
  database: process.env.DB_NAME,
  ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
  entities: [join(__dirname, '..', '**', `*.entity.${EXT}`)],
  migrations: [join(__dirname, 'migrations', `*.${EXT}`)],
  synchronize: false,
  migrationsRun: false,
});

/** DataSource instance consumed by `typeorm` CLI (see package.json scripts). */
export default new DataSource(buildDataSourceOptions());
