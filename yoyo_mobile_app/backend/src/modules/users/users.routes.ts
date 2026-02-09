import { Router } from 'express';
import { query } from '../../config/db.js';
import { requireAuth, requireRole } from '../auth/auth.middleware.js';
import { Role } from '../../common/types.js';

export const usersRouter = Router();

usersRouter.get('/', requireAuth, requireRole(['manager']), async (_req, res) => {
  const result = await query<{
    id: number;
    name: string;
    email: string;
    role: Role;
  }>('SELECT id, name, email, role FROM users ORDER BY created_at DESC');

  return res.json(result.rows);
});
