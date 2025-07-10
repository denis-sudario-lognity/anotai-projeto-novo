/*
  # Schema Inicial do Banco de Dados

  Este script consolida a criação de todas as tabelas principais, funções, gatilhos e políticas de segurança para garantir a correta ordem de execução e evitar erros de dependência.

  1. Funções Utilitárias
     - `moddatetime`: Atualiza o campo `updated_at` automaticamente.

  2. Novas Tabelas
     - `profiles`: Armazena dados de perfil dos usuários.
     - `wallets`: Contas financeiras dos usuários.
     - `categories`: Categorias para transações (com dados iniciais do sistema).
     - `transactions`: Registros de movimentações financeiras.

  3. Segurança
     - RLS habilitado em todas as tabelas.
     - Políticas de acesso definidas para cada tabela.

  4. Triggers
     - Gatilhos de `updated_at` para todas as tabelas.
*/

-- 1. Extensões e Funções Utilitárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS "pg_trgm" WITH SCHEMA extensions;

CREATE OR REPLACE FUNCTION public.moddatetime()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Tabela de Perfis (Profiles)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Usuários podem visualizar seus próprios perfis" ON public.profiles;
CREATE POLICY "Usuários podem visualizar seus próprios perfis"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "Usuários podem atualizar seus próprios perfis" ON public.profiles;
CREATE POLICY "Usuários podem atualizar seus próprios perfis"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

DROP TRIGGER IF EXISTS set_updated_at ON public.profiles;
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.moddatetime();

-- 3. Tabela de Carteiras (Wallets)
CREATE TABLE IF NOT EXISTS public.wallets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'checking',
  balance NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_wallets_user_id ON public.wallets(user_id);

ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Usuários podem gerenciar suas próprias carteiras" ON public.wallets;
CREATE POLICY "Usuários podem gerenciar suas próprias carteiras"
  ON public.wallets FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP TRIGGER IF EXISTS set_updated_at ON public.wallets;
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.wallets
  FOR EACH ROW
  EXECUTE FUNCTION public.moddatetime();

-- 4. Tabela de Categorias (Categories)
CREATE TABLE IF NOT EXISTS public.categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  color TEXT DEFAULT '#6366F1',
  icon TEXT DEFAULT 'tag',
  type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  is_system BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_categories_user_id ON public.categories(user_id);
CREATE INDEX IF NOT EXISTS idx_categories_type ON public.categories(type);

ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Usuários podem visualizar categorias do sistema e suas próprias" ON public.categories;
CREATE POLICY "Usuários podem visualizar categorias do sistema e suas próprias"
  ON public.categories FOR SELECT
  USING (is_system OR auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários podem inserir suas próprias categorias" ON public.categories;
CREATE POLICY "Usuários podem inserir suas próprias categorias"
  ON public.categories FOR INSERT
  WITH CHECK (auth.uid() = user_id AND NOT is_system);

DROP POLICY IF EXISTS "Usuários podem atualizar suas próprias categorias" ON public.categories;
CREATE POLICY "Usuários podem atualizar suas próprias categorias"
  ON public.categories FOR UPDATE
  USING (auth.uid() = user_id AND NOT is_system);

DROP POLICY IF EXISTS "Usuários podem excluir suas próprias categorias" ON public.categories;
CREATE POLICY "Usuários podem excluir suas próprias categorias"
  ON public.categories FOR DELETE
  USING (auth.uid() = user_id AND NOT is_system);

DROP TRIGGER IF EXISTS set_updated_at ON public.categories;
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.categories
  FOR EACH ROW
  EXECUTE FUNCTION public.moddatetime();

-- Dados Iniciais para Categorias
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.categories WHERE is_system = TRUE AND user_id IS NULL) THEN
    INSERT INTO public.categories (user_id, name, description, color, icon, type, is_system)
    VALUES
      (NULL, 'Salário', 'Rendimentos do trabalho', '#10B981', 'briefcase', 'income', TRUE),
      (NULL, 'Investimentos', 'Rendimentos de investimentos', '#6366F1', 'trending-up', 'income', TRUE),
      (NULL, 'Freelance', 'Trabalhos extras', '#F59E0B', 'code', 'income', TRUE),
      (NULL, 'Presentes', 'Dinheiro recebido como presente', '#EC4899', 'gift', 'income', TRUE),
      (NULL, 'Outros', 'Outras receitas', '#6B7280', 'plus-circle', 'income', TRUE),
      (NULL, 'Alimentação', 'Restaurantes, mercado, delivery', '#EF4444', 'utensils', 'expense', TRUE),
      (NULL, 'Moradia', 'Aluguel, condomínio, IPTU', '#8B5CF6', 'home', 'expense', TRUE),
      (NULL, 'Transporte', 'Combustível, transporte público, apps', '#F97316', 'car', 'expense', TRUE),
      (NULL, 'Lazer', 'Cinema, viagens, hobbies', '#06B6D4', 'film', 'expense', TRUE),
      (NULL, 'Saúde', 'Consultas, medicamentos, plano de saúde', '#10B981', 'activity', 'expense', TRUE),
      (NULL, 'Educação', 'Cursos, livros, material escolar', '#3B82F6', 'book', 'expense', TRUE),
      (NULL, 'Compras', 'Roupas, eletrônicos, presentes', '#EC4899', 'shopping-bag', 'expense', TRUE),
      (NULL, 'Contas', 'Água, luz, internet, telefone', '#F59E0B', 'file-text', 'expense', TRUE),
      (NULL, 'Outros', 'Outras despesas', '#6B7280', 'more-horizontal', 'expense', TRUE);
  END IF;
END $$;

-- 5. Tabela de Transações (Transactions)
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

CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON public.transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_wallet_id ON public.transactions(wallet_id);
CREATE INDEX IF NOT EXISTS idx_transactions_category_id ON public.transactions(category_id);

ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Usuários podem gerenciar suas próprias transações" ON public.transactions;
CREATE POLICY "Usuários podem gerenciar suas próprias transações"
  ON public.transactions FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP TRIGGER IF EXISTS set_updated_at ON public.transactions;
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.transactions
  FOR EACH ROW
  EXECUTE FUNCTION public.moddatetime();