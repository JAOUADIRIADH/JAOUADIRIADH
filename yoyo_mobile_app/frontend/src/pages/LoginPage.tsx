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
import { useNavigate } from 'react-router-dom';
import { api } from '../services/api';
import { useAuth } from '../stores/authStore';

const LoginPage = () => {
  const navigate = useNavigate();
  const { login } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async () => {
    setError(null);
    try {
      const result = await api.login(email, password);
      login(result.token, result.user);
      navigate('/pos');
    } catch (err) {
      setError((err as Error).message);
    }
  };

  return (
    <IonPage>
      <IonHeader>
        <IonToolbar>
          <IonTitle>Connexion</IonTitle>
        </IonToolbar>
      </IonHeader>
      <IonContent className="ion-padding">
        <IonItem>
          <IonLabel position="stacked">Email</IonLabel>
          <IonInput
            value={email}
            onIonChange={(event) => setEmail(event.detail.value ?? '')}
            type="email"
          />
        </IonItem>
        <IonItem>
          <IonLabel position="stacked">Mot de passe</IonLabel>
          <IonInput
            value={password}
            onIonChange={(event) => setPassword(event.detail.value ?? '')}
            type="password"
          />
        </IonItem>
        {error && <p style={{ color: 'var(--ion-color-danger)' }}>{error}</p>}
        <IonButton expand="block" onClick={handleSubmit} style={{ marginTop: 16 }}>
          Se connecter
        </IonButton>
      </IonContent>
    </IonPage>
  );
};

export default LoginPage;
