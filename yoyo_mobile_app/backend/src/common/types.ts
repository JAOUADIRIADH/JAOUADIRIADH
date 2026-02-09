export type Role = 'serveur' | 'caissier' | 'manager';

export interface AuthPayload {
  userId: number;
  role: Role;
}
