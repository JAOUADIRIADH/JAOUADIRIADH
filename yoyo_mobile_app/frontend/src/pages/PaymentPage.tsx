import { useState } from 'react';
import {
  IonButton,
  IonContent,
  IonHeader,
  IonInput,
  IonItem,
  IonLabel,
  IonPage,
  IonTitle,
  IonToolbar
} from '@ionic/react';
import { api } from '../services/api';
import { useAuth } from '../stores/authStore';

const PaymentPage = () => {
  const { token } = useAuth();
  const [orderId, setOrderId] = useState('');
  const [message, setMessage] = useState('');

  const handlePay = async () => {
    if (!token) return;
    try {
      const result = await api.payOrder(token, Number(orderId));
      setMessage(`Paiement OK: ${(result.total_cents / 100).toFixed(2)} €`);
    } catch (error) {
      setMessage('Erreur lors du paiement.');
    }
  };

  return (
    <IonPage>
      <IonHeader>
        <IonToolbar>
          <IonTitle>Paiement</IonTitle>
        </IonToolbar>
      </IonHeader>
      <IonContent className="ion-padding">
        <IonItem>
          <IonLabel position="stacked">ID Commande</IonLabel>
          <IonInput value={orderId} onIonChange={(e) => setOrderId(e.detail.value ?? '')} />
        </IonItem>
        <IonButton expand="block" onClick={handlePay} style={{ marginTop: 16 }}>
          Encaisser
        </IonButton>
        {message && <p>{message}</p>}
      </IonContent>
    </IonPage>
  );
};

export default PaymentPage;
