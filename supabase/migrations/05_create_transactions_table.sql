/*
  # Criação da Tabela de Transações (Transactions)

  Este é o script central da aplicação, criando a tabela `transactions` para registrar todas as movimentações financeiras.

  1. Nova Tabela
     - `transactions`: Armazena as transações.
       - `user_id`, `wallet_id`, `category_id`: Chaves estrangeiras.
       - `amount`: Valor da transação.
       - `type`: 'income' ou 'expense'.
       - `date`: Data em que a transação ocorreu.

  2. Índices
     - Otimiza consultas por usuário, carteira e categoria.

  3. Segurança
     - Habilita RLS.
     - Política `FOR ALL`: Permite que usuários gerenciem (CRUD) suas próprias transações.

  4. Triggers
     - `set_updated_at`: Atualiza `updated_at` em cada modificação.
*/

-- 1. Criação da Tabela
CREATE TABLE IF NOT EXISTS public.transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  wallet_id UUID NOT NULL REFERENCES public.wallets(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
  amount NUMERIC(10, 2) NOT NULL,
  description TEXT,
  type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Índices
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON public.transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_wallet_id ON public.transactions(wallet_id);
CREATE INDEX IF NOT EXISTS idx_transactions_category_id ON public.transactions(category_id);

-- 3. Segurança
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Usuários podem gerenciar suas próprias transações" ON public.transactions;
CREATE POLICY "Usuários podem gerenciar suas próprias transações"
  ON public.transactions FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 4. Triggers
DROP TRIGGER IF EXISTS set_updated_at ON public.transactions;
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.transactions
  FOR EACH ROW
  EXECUTE FUNCTION public.moddatetime();