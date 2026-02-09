import { Router } from 'express';
import { query } from '../../config/db.js';
import { requireAuth, requireRole } from '../auth/auth.middleware.js';

export const productsRouter = Router();

productsRouter.get('/', requireAuth, async (_req, res) => {
  const result = await query(
    `SELECT products.id, products.name, products.price_cents, products.category_id, products.is_active,
            categories.name AS category_name
     FROM products
     LEFT JOIN categories ON products.category_id = categories.id
     ORDER BY products.created_at DESC`
  );
  return res.json(result.rows);
});

productsRouter.post('/', requireAuth, requireRole(['manager']), async (req, res) => {
  const { name, price_cents, category_id } = req.body as {
    name: string;
    price_cents: number;
    category_id?: number;
  };

  if (!name || price_cents == null) {
    return res.status(400).json({ message: 'Nom et prix requis.' });
  }

  const result = await query(
    'INSERT INTO products (name, price_cents, category_id) VALUES ($1, $2, $3) RETURNING *',
    [name, price_cents, category_id ?? null]
  );

  return res.status(201).json(result.rows[0]);
});

productsRouter.put('/:id', requireAuth, requireRole(['manager']), async (req, res) => {
  const { name, price_cents, category_id, is_active } = req.body as {
    name: string;
    price_cents: number;
    category_id?: number;
    is_active?: boolean;
  };

  const result = await query(
    'UPDATE products SET name = $1, price_cents = $2, category_id = $3, is_active = $4 WHERE id = $5 RETURNING *',
    [name, price_cents, category_id ?? null, is_active ?? true, Number(req.params.id)]
  );

  return res.json(result.rows[0]);
});

productsRouter.delete('/:id', requireAuth, requireRole(['manager']), async (req, res) => {
  await query('DELETE FROM products WHERE id = $1', [Number(req.params.id)]);
  return res.status(204).send();
});
