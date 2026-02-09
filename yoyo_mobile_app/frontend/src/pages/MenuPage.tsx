import {
  IonContent,
  IonHeader,
  IonPage,
  IonTitle,
  IonToolbar,
  IonList,
  IonItem,
  IonLabel
} from '@ionic/react';

const MenuPage = () => (
  <IonPage>
    <IonHeader>
      <IonToolbar>
        <IonTitle>Menu</IonTitle>
      </IonToolbar>
    </IonHeader>
    <IonContent className="ion-padding">
      <IonList>
        <IonItem>
          <IonLabel>Catégories & Produits (à connecter à l'API)</IonLabel>
        </IonItem>
      </IonList>
    </IonContent>
  </IonPage>
);

export default MenuPage;
