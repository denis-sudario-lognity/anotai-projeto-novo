/*
  # Criação da Tabela de Carteiras (Wallets)

  Este script cria a tabela `wallets` para que os usuários possam gerenciar suas contas financeiras (ex: conta corrente, poupança).

  1. Nova Tabela
     - `wallets`: Armazena as contas financeiras dos usuários.
       - `id`: Chave primária.
       - `user_id`: Referência ao perfil do usuário.
       - `name`: Nome da carteira (ex: "Banco Principal").
       - `type`: Tipo de conta (ex: 'checking', 'savings').
       - `balance`: Saldo atual da carteira.
       - `created_at`, `updated_at`: Timestamps.

  2. Índices
     - `idx_wallets_user_id`: Para otimizar consultas por usuário.

  3. Segurança
     - Habilita RLS na tabela.
     - Política `FOR ALL`: Permite que usuários criem, leiam, atualizem e deletem suas próprias carteiras.

  4. Triggers
     - `set_updated_at`: Atualiza `updated_at` em cada modificação.
*/

-- 1. Criação da Tabela
CREATE TABLE IF NOT EXISTS public.wallets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'checking',
  balance NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Índices
CREATE INDEX IF NOT EXISTS idx_wallets_user_id ON public.wallets(user_id);

-- 3. Segurança
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Usuários podem gerenciar suas próprias carteiras" ON public.wallets;
CREATE POLICY "Usuários podem gerenciar suas próprias carteiras"
  ON public.wallets FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 4. Triggers
DROP TRIGGER IF EXISTS set_updated_at ON public.wallets;
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.wallets
  FOR EACH ROW
  EXECUTE FUNCTION public.moddatetime();