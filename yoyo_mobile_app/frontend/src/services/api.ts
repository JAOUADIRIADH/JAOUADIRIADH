import { User } from '../stores/authStore';

const baseUrl = import.meta.env.VITE_API_URL ?? 'http://localhost:4000';

const request = async <T>(path: string, options: RequestInit = {}) => {
  const response = await fetch(`${baseUrl}${path}`, {
    headers: {
      'Content-Type': 'application/json',
      ...(options.headers ?? {})
    },
    ...options
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(error.message ?? 'Erreur API');
  }

  return (await response.json()) as T;
};

export const api = {
  login: (email: string, password: string) =>
    request<{ token: string; user: User }>('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password })
    }),
  getProducts: (token: string) =>
    request<Array<{ id: number; name: string; price_cents: number }>>('/products', {
      headers: { Authorization: `Bearer ${token}` }
    }),
  createOrder: (token: string) =>
    request<{ id: number; total_cents: number }>(`/orders`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}` }
    }),
  addOrderItem: (token: string, orderId: number, productId: number, quantity: number) =>
    request<{ total_cents: number }>(`/orders/${orderId}/items`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}` },
      body: JSON.stringify({ product_id: productId, quantity })
    }),
  listOrders: (token: string) =>
    request<Array<{ id: number; status: string; total_cents: number }>>('/orders', {
      headers: { Authorization: `Bearer ${token}` }
    }),
  payOrder: (token: string, orderId: number) =>
    request<{ status: string; total_cents: number }>(`/orders/${orderId}/pay`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}` }
    })
};
