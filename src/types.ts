export interface User {
  id: string;
  email: string;
  created_at: string;
}

export interface Wallet {
  id: string;
  name: string;
  balance: number;
  currency: string;
  user_id: string;
  created_at: string;
  updated_at: string;
}

export interface Category {
  id: string;
  name: string;
  user_id: string;
  created_at: string;
}

export interface Budget {
  id: string;
  name: string;
  amount: number;
  category_id: string;
  user_id: string;
  description?: string;
  created_at: string;
  updated_at: string;
}

export interface Transaction {
  id: string;
  amount: number;
  description: string;
  date: string;
  type: 'income' | 'expense' | 'transfer';
  category_id?: string;
  wallet_id: string;
  user_id: string;
  created_at: string;
}
