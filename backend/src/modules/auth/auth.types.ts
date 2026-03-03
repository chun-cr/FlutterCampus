export type AuthUser = {
  userId: string;
  email: string;
};

export type PublicUser = {
  id: string;
  email: string;
  username: string;
  name: string;
  phone: string;
  type: string;
  studentId?: string | null;
  department?: string | null;
  avatar?: string | null;
};
