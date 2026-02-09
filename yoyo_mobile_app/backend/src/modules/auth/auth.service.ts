import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { env } from '../../config/env.js';
import { query } from '../../config/db.js';
import { AuthPayload, Role } from '../../common/types.js';

interface UserRow {
  id: number;
  name: string;
  email: string;
  password_hash: string;
  role: Role;
}

export const hashPassword = async (password: string) => bcrypt.hash(password, 10);

export const verifyPassword = async (password: string, passwordHash: string) =>
  bcrypt.compare(password, passwordHash);

export const signToken = (payload: AuthPayload) =>
  jwt.sign(payload, env.jwtSecret, { expiresIn: env.jwtExpiresIn });

export const findUserByEmail = async (email: string) => {
  const result = await query<UserRow>('SELECT * FROM users WHERE email = $1', [email]);
  return result.rows[0];
};

export const createUser = async (name: string, email: string, password: string, role: Role) => {
  const passwordHash = await hashPassword(password);
  const result = await query<UserRow>(
    'INSERT INTO users (name, email, password_hash, role) VALUES ($1, $2, $3, $4) RETURNING *',
    [name, email, passwordHash, role]
  );
  return result.rows[0];
};
