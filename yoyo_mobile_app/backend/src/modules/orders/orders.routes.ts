import { Router } from 'express';
import { query, db } from '../../config/db.js';
import { requireAuth, requireRole } from '../auth/auth.middleware.js';

export const ordersRouter = Router();

const calculateTotal = async (orderId: number) => {
  const result = await query<{ total_cents: number }>(
    'SELECT COALESCE(SUM(quantity * unit_price_cents), 0) AS total_cents FROM order_items WHERE order_id = $1',
    [orderId]
  );
  const total = result.rows[0]?.total_cents ?? 0;
  await query('UPDATE orders SET total_cents = $1 WHERE id = $2', [total, orderId]);
  return total;
};

ordersRouter.get('/', requireAuth, async (_req, res) => {
  const result = await query(
    `SELECT orders.*, users.name AS created_by_name
     FROM orders
     LEFT JOIN users ON orders.created_by = users.id
     ORDER BY orders.created_at DESC`
  );
  return res.json(result.rows);
});

ordersRouter.post('/', requireAuth, async (req, res) => {
  const userId = req.auth?.userId ?? null;
  const result = await query('INSERT INTO orders (status, total_cents, created_by) VALUES ($1, $2, $3) RETURNING *', [
    'open',
    0,
    userId
  ]);
  return res.status(201).json(result.rows[0]);
});

ordersRouter.post('/:id/items', requireAuth, async (req, res) => {
  const { product_id, quantity } = req.body as { product_id: number; quantity: number };

  const productResult = await query<{ price_cents: number }>('SELECT price_cents FROM products WHERE id = $1', [
    product_id
  ]);
  const product = productResult.rows[0];
  if (!product) {
    return res.status(404).json({ message: 'Produit introuvable.' });
  }

  await query(
    'INSERT INTO order_items (order_id, product_id, quantity, unit_price_cents) VALUES ($1, $2, $3, $4)',
    [Number(req.params.id), product_id, quantity, product.price_cents]
  );

  const total = await calculateTotal(Number(req.params.id));
  return res.json({ total_cents: total });
});

ordersRouter.delete('/:orderId/items/:itemId', requireAuth, async (req, res) => {
  await query('DELETE FROM order_items WHERE id = $1 AND order_id = $2', [
    Number(req.params.itemId),
    Number(req.params.orderId)
  ]);
  const total = await calculateTotal(Number(req.params.orderId));
  return res.json({ total_cents: total });
});

ordersRouter.post('/:id/pay', requireAuth, requireRole(['caissier', 'manager']), async (req, res) => {
  const client = await db.connect();
  try {
    await client.query('BEGIN');
    const totalResult = await client.query<{ total_cents: number }>(
      'SELECT total_cents FROM orders WHERE id = $1 FOR UPDATE',
      [Number(req.params.id)]
    );
    const total = totalResult.rows[0]?.total_cents ?? 0;

    await client.query('UPDATE orders SET status = $1 WHERE id = $2', ['paid', Number(req.params.id)]);
    await client.query('COMMIT');
    return res.json({ status: 'paid', total_cents: total });
  } catch (error) {
    await client.query('ROLLBACK');
    return res.status(500).json({ message: 'Erreur paiement.' });
  } finally {
    client.release();
  }
});
