import { useEffect, useState } from 'react';
import {
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
import { useAuth } from '../stores/authStore';

interface Order {
  id: number;
  status: string;
  total_cents: number;
}

const OrdersPage = () => {
  const { token } = useAuth();
  const [orders, setOrders] = useState<Order[]>([]);

  useEffect(() => {
    if (!token) return;
    api.listOrders(token).then(setOrders).catch(() => setOrders([]));
  }, [token]);

  return (
    <IonPage>
      <IonHeader>
        <IonToolbar>
          <IonTitle>Commandes</IonTitle>
        </IonToolbar>
      </IonHeader>
      <IonContent className="ion-padding">
        <IonList>
          {orders.map((order) => (
            <IonItem key={order.id}>
              <IonLabel>
                #{order.id} - {order.status} - {(order.total_cents / 100).toFixed(2)} €
              </IonLabel>
            </IonItem>
          ))}
        </IonList>
      </IonContent>
    </IonPage>
  );
};

export default OrdersPage;
