import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { env } from '../../config/env.js';
import { AuthPayload, Role } from '../../common/types.js';

declare module 'express-serve-static-core' {
  interface Request {
    auth?: AuthPayload;
  }
}

export const requireAuth = (req: Request, res: Response, next: NextFunction) => {
  const header = req.headers.authorization;
  if (!header) {
    return res.status(401).json({ message: 'Authorization manquante.' });
  }

  const token = header.replace('Bearer ', '');
  try {
    const payload = jwt.verify(token, env.jwtSecret) as AuthPayload;
    req.auth = payload;
    return next();
  } catch (error) {
    return res.status(401).json({ message: 'Token invalide.' });
  }
};

export const requireRole = (roles: Role[]) => (req: Request, res: Response, next: NextFunction) => {
  if (!req.auth || !roles.includes(req.auth.role)) {
    return res.status(403).json({ message: 'Accès refusé.' });
  }
  return next();
};
