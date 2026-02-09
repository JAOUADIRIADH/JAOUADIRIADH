import { Router } from 'express';
import { createUser, findUserByEmail, signToken, verifyPassword } from './auth.service.js';
import { Role } from '../../common/types.js';

export const authRouter = Router();

// Inscription d'un utilisateur (ex: manager initial)
authRouter.post('/register', async (req, res) => {
  const { name, email, password, role } = req.body as {
    name: string;
    email: string;
    password: string;
    role: Role;
  };

  if (!name || !email || !password || !role) {
    return res.status(400).json({ message: 'Champs requis manquants.' });
  }

  const existingUser = await findUserByEmail(email);
  if (existingUser) {
    return res.status(409).json({ message: 'Email déjà utilisé.' });
  }

  const user = await createUser(name, email, password, role);
  const token = signToken({ userId: user.id, role: user.role });

  return res.json({
    token,
    user: { id: user.id, name: user.name, email: user.email, role: user.role }
  });
});

// Connexion
authRouter.post('/login', async (req, res) => {
  const { email, password } = req.body as { email: string; password: string };

  if (!email || !password) {
    return res.status(400).json({ message: 'Email et mot de passe requis.' });
  }

  const user = await findUserByEmail(email);
  if (!user) {
    return res.status(401).json({ message: 'Identifiants invalides.' });
  }

  const isValid = await verifyPassword(password, user.password_hash);
  if (!isValid) {
    return res.status(401).json({ message: 'Identifiants invalides.' });
  }

  const token = signToken({ userId: user.id, role: user.role });
  return res.json({
    token,
    user: { id: user.id, name: user.name, email: user.email, role: user.role }
  });
});
