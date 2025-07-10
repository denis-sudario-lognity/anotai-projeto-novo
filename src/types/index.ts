export type Budget = {
  id: string;
  name: string;
  amount: number;
  category_id: string;
  user_id: string;
  created_at: string;
  workspace_id?: string | null;
};

export type Category = {
  id: string;
  name: string;
  icon: string | null;
  color: string | null;
  type: "income" | "expense";
  user_id: string | null;
  is_system: boolean;
  created_at: string;
  workspace_id?: string | null;
};

export type Wallet = {
  id: string;
  name: string;
  balance: number;
  color: string | null;
  icon: string | null;
  is_default: boolean;
  user_id: string;
  created_at: string;
  workspace_id?: string | null;
};

export type CreditCard = {
  id: string;
  name: string;
  limit: number;
  available_credit: number;
  closing_day: number;
  due_day: number;
  color: string | null;
  wallet_id: string;
  user_id: string;
  created_at: string;
  workspace_id?: string | null;
};

export type Transaction = {
  id: string;
  description: string;
  amount: number;
  type: "income" | "expense" | "transfer";
  date: string;
  is_paid: boolean;
  is_recurring: boolean;
  recurrence_frequency?: "daily" | "weekly" | "monthly" | "yearly" | null;
  recurrence_end_date?: string | null;
  notes?: string | null;
  user_id: string;
  wallet_id: string;
  category_id?: string | null;
  credit_card_id?: string | null;
  created_at: string;
  updated_at: string;
  workspace_id?: string | null;
  
  // Relações expandidas
  wallet?: Wallet;
  category?: Category;
  credit_card?: CreditCard;
};

export type TransactionWithRelations = Transaction & {
  wallet: Wallet;
  category?: Category;
  credit_card?: CreditCard;
};

export type TransactionFilters = {
  startDate?: string;
  endDate?: string;
  type?: "income" | "expense" | "transfer" | "all";
  walletId?: string;
  categoryId?: string;
  creditCardId?: string;
  isPaid?: boolean;
  search?: string;
  minAmount?: number;
  maxAmount?: number;
};

export type TransactionFormValues = {
  description: string;
  amount: number;
  type: "income" | "expense" | "transfer";
  date: Date;
  is_paid: boolean;
  is_recurring: boolean;
  recurrence_frequency?: "daily" | "weekly" | "monthly" | "yearly" | null;
  recurrence_end_date?: Date | null;
  notes?: string | null;
  wallet_id: string;
  category_id?: string | null;
  credit_card_id?: string | null;
  workspace_id?: string | null;
};

export type Workspace = {
  id: string;
  name: string;
  description?: string | null;
  owner_id: string;
  created_at: string;
  updated_at: string;
};

export type WorkspaceMember = {
  workspace_id: string;
  user_id: string;
  role: "owner" | "admin" | "member" | "viewer";
  created_at: string;
  updated_at: string;
};

export type Notification = {
  id: string;
  title: string;
  message: string;
  type: "info" | "success" | "warning" | "error";
  link?: string | null;
  is_read: boolean;
  created_at: string;
};

export type SubscriptionPlan = {
  id: string;
  name: string;
  description?: string | null;
  price: number;
  interval: "monthly" | "yearly";
  features: Array<{
    name: string;
    included: boolean;
  }>;
  is_active: boolean;
};

export type Subscription = {
  id: string;
  user_id: string;
  plan_id: string;
  status: "active" | "canceled" | "expired";
  current_period_start: string;
  current_period_end: string;
  cancel_at_period_end: boolean;
  created_at: string;
  updated_at: string;
  plan?: SubscriptionPlan;
};

export type MonthlySummary = {
  month: number;
  year: number;
  total_income: number;
  total_expense: number;
  balance: number;
};

export type CategorySummary = {
  category_id: string;
  category_name: string;
  category_color: string;
  category_icon: string;
  total_amount: number;
  percentage: number;
};

export type CashFlow = {
  date: string;
  income: number;
  expense: number;
  balance: number;
};
