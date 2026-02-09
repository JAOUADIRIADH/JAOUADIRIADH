import { useEffect, useState } from 'react';
import {
  IonButton,
  IonCard,
  IonCardContent,
  IonContent,
  IonHeader,
  IonItem,
  IonLabel,
  IonList,
  IonPage,
  IonTitle,
  IonToolbar
} from '@ionic/react';
import { api } from '../services/api';
import { offlineStore } from '../services/offlineStore';
import { useAuth } from '../stores/authStore';

interface Product {
  id: number;
  name: string;
  price_cents: number;
}

const PosPage = () => {
  const { token, user } = useAuth();
  const [products, setProducts] = useState<Product[]>([]);
  const [orderId, setOrderId] = useState<number | null>(null);
  const [total, setTotal] = useState(0);
  const [status, setStatus] = useState('');

  useEffect(() => {
    if (!token) return;

    const load = async () => {
      try {
        const list = await api.getProducts(token);
        setProducts(list);
      } catch (error) {
        setStatus('Mode hors-ligne: produits indisponibles.');
      }
    };

    load();
  }, [token]);

  const ensureOrder = async () => {
    if (!token) return null;
    if (orderId) return orderId;

    const order = await api.createOrder(token);
    setOrderId(order.id);
    return order.id;
  };

  const addItem = async (product: Product) => {
    if (!token) return;
    try {
      const id = await ensureOrder();
      if (!id) return;
      const result = await api.addOrderItem(token, id, product.id, 1);
      setTotal(result.total_cents);
      setStatus('');
    } catch (error) {
      await offlineStore.add({ product, quantity: 1, user });
      setStatus('Ajouté en file hors-ligne.');
    }
  };

  return (
    <IonPage>
      <IonHeader>
        <IonToolbar>
          <IonTitle>POS - Caisse</IonTitle>
        </IonToolbar>
      </IonHeader>
      <IonContent className="ion-padding">
        {status && <p>{status}</p>}
        <IonCard>
          <IonCardContent>
            <h2>Total: {(total / 100).toFixed(2)} €</h2>
            <p>Opérateur: {user?.name ?? 'N/A'}</p>
          </IonCardContent>
        </IonCard>
        <IonList>
          {products.map((product) => (
            <IonItem key={product.id}>
              <IonLabel>
                {product.name} - {(product.price_cents / 100).toFixed(2)} €
              </IonLabel>
              <IonButton slot="end" onClick={() => addItem(product)}>
                Ajouter
              </IonButton>
            </IonItem>
          ))}
        </IonList>
      </IonContent>
    </IonPage>
  );
};

export default PosPage;
