import { Pool } from 'pg';
import { env } from './env.js';

export const db = new Pool({
  connectionString: env.databaseUrl
});

export const query = async <T>(text: string, params?: Array<string | number | boolean | null>) => {
  const result = await db.query<T>(text, params);
  return result;
};
