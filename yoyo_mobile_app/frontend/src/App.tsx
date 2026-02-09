import { IonRouterOutlet } from '@ionic/react';
import { IonReactRouter } from '@ionic/react-router';
import { Redirect, Route } from 'react-router-dom';
import { AuthProvider } from './stores/authStore';
import LoginPage from './pages/LoginPage';
import PosPage from './pages/PosPage';
import MenuPage from './pages/MenuPage';
import OrdersPage from './pages/OrdersPage';
import PaymentPage from './pages/PaymentPage';

const App = () => (
  <AuthProvider>
    <IonReactRouter>
      <IonRouterOutlet>
        <Route path="/login" component={LoginPage} exact />
        <Route path="/pos" component={PosPage} exact />
        <Route path="/menu" component={MenuPage} exact />
        <Route path="/orders" component={OrdersPage} exact />
        <Route path="/payment" component={PaymentPage} exact />
        <Redirect exact from="/" to="/login" />
      </IonRouterOutlet>
    </IonReactRouter>
  </AuthProvider>
);

export default App;
