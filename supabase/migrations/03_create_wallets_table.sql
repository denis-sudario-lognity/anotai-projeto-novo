/*
  # Criação da tabela de carteiras
  
  1. Nova Tabela
     - `wallets`: Armazena informações sobre as carteiras financeiras dos usuários
       - `id` (uuid, chave primária)
       - `user_id` (uuid, referência a profiles.id)
       - `name` (texto)
       - `description` (texto)
       - `balance` (decimal)
       - `currency` (texto)
       - `is_default` (booleano)
       - `created_at` (timestamp)
       - `updated_at` (timestamp)
  
  2. Segurança
     - Habilita RLS na tabela `wallets`
     - Adiciona políticas para usuários autenticados
*/

-- Criação da tabela de carteiras
CREATE TABLE IF NOT EXISTS public.wallets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  balance DECIMAL(15, 2) DEFAULT 0.00,
  currency TEXT DEFAULT 'BRL',
  is_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_wallets_user_id ON public.wallets(user_id);

-- Configuração de segurança
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
CREATE POLICY "Usuários podem visualizar suas próprias carteiras"
  ON public.wallets
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem inserir suas próprias carteiras"
  ON public.wallets
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar suas próprias carteiras"
  ON public.wallets
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem excluir suas próprias carteiras"
  ON public.wallets
  FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger para atualizar o timestamp
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.wallets
  FOR EACH ROW
  EXECUTE FUNCTION public.moddatetime();
