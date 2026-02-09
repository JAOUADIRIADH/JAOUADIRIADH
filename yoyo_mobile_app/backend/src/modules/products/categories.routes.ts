import { Router } from 'express';
import { query } from '../../config/db.js';
import { requireAuth, requireRole } from '../auth/auth.middleware.js';

export const categoriesRouter = Router();

categoriesRouter.get('/', requireAuth, async (_req, res) => {
  const result = await query('SELECT * FROM categories ORDER BY created_at DESC');
  return res.json(result.rows);
});

categoriesRouter.post('/', requireAuth, requireRole(['manager']), async (req, res) => {
  const { name } = req.body as { name: string };
  if (!name) {
    return res.status(400).json({ message: 'Nom requis.' });
  }
  const result = await query('INSERT INTO categories (name) VALUES ($1) RETURNING *', [name]);
  return res.status(201).json(result.rows[0]);
});

categoriesRouter.put('/:id', requireAuth, requireRole(['manager']), async (req, res) => {
  const { name } = req.body as { name: string };
  const result = await query('UPDATE categories SET name = $1 WHERE id = $2 RETURNING *', [
    name,
    Number(req.params.id)
  ]);
  return res.json(result.rows[0]);
});

categoriesRouter.delete('/:id', requireAuth, requireRole(['manager']), async (req, res) => {
  await query('DELETE FROM categories WHERE id = $1', [Number(req.params.id)]);
  return res.status(204).send();
});
