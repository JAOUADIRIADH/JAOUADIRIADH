import express from 'express';
import cors from 'cors';
import { env } from './config/env.js';
import { authRouter } from './modules/auth/auth.routes.js';
import { usersRouter } from './modules/users/users.routes.js';
import { productsRouter } from './modules/products/products.routes.js';
import { categoriesRouter } from './modules/products/categories.routes.js';
import { ordersRouter } from './modules/orders/orders.routes.js';

const app = express();

app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => res.json({ status: 'ok' }));

app.use('/auth', authRouter);
app.use('/users', usersRouter);
app.use('/categories', categoriesRouter);
app.use('/products', productsRouter);
app.use('/orders', ordersRouter);

app.listen(env.port, () => {
  console.log(`API running on http://localhost:${env.port}`);
});
