/*
  # Criação da tabela de cartões de crédito
  
  1. Nova Tabela
     - `credit_cards`: Armazena informações sobre os cartões de crédito dos usuários
       - `id` (uuid, chave primária)
       - `user_id` (uuid, referência a profiles.id)
       - `wallet_id` (uuid, referência a wallets.id)
       - `name` (texto)
       - `last_digits` (texto)
       - `expiry_date` (data)
       - `credit_limit` (decimal)
       - `available_credit` (decimal)
       - `closing_day` (inteiro)
       - `due_day` (inteiro)
       - `created_at` (timestamp)
       - `updated_at` (timestamp)
  
  2. Segurança
     - Habilita RLS na tabela `credit_cards`
     - Adiciona políticas para usuários autenticados
*/

-- Criação da tabela de cartões de crédito
CREATE TABLE IF NOT EXISTS public.credit_cards (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  wallet_id UUID NOT NULL REFERENCES public.wallets(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  last_digits TEXT,
  expiry_date DATE,
  credit_limit DECIMAL(15, 2) DEFAULT 0.00,
  available_credit DECIMAL(15, 2) DEFAULT 0.00,
  closing_day INTEGER CHECK (closing_day BETWEEN 1 AND 31),
  due_day INTEGER CHECK (due_day BETWEEN 1 AND 31),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_credit_cards_user_id ON public.credit_cards(user_id);
CREATE INDEX idx_credit_cards_wallet_id ON public.credit_cards(wallet_id);

-- Configuração de segurança
ALTER TABLE public.credit_cards ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
CREATE POLICY "Usuários podem visualizar seus próprios cartões de crédito"
  ON public.credit_cards
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem inserir seus próprios cartões de crédito"
  ON public.credit_cards
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seus próprios cartões de crédito"
  ON public.credit_cards
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem excluir seus próprios cartões de crédito"
  ON public.credit_cards
  FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger para atualizar o timestamp
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.credit_cards
  FOR EACH ROW
  EXECUTE FUNCTION public.moddatetime();
