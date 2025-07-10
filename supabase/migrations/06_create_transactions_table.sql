/*
  # Criação da tabela de transações
  
  1. Nova Tabela
     - `transactions`: Armazena todas as transações financeiras
       - `id` (uuid, chave primária)
       - `user_id` (uuid, referência a profiles.id)
       - `wallet_id` (uuid, referência a wallets.id)
       - `category_id` (uuid, referência a categories.id)
       - `credit_card_id` (uuid, referência a credit_cards.id, opcional)
       - `description` (texto)
       - `amount` (decimal)
       - `type` (texto: 'income', 'expense', 'transfer')
       - `date` (data)
       - `is_paid` (booleano)
       - `is_recurring` (booleano)
       - `recurrence_frequency` (texto, opcional)
       - `recurrence_end_date` (data, opcional)
       - `notes` (texto)
       - `created_at` (timestamp)
       - `updated_at` (timestamp)
  
  2. Segurança
     - Habilita RLS na tabela `transactions`
     - Adiciona políticas para usuários autenticados
*/

-- Criação da tabela de transações
CREATE TABLE IF NOT EXISTS public.transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  wallet_id UUID NOT NULL REFERENCES public.wallets(id) ON DELETE CASCADE,
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  credit_card_id UUID REFERENCES public.credit_cards(id) ON DELETE SET NULL,
  description TEXT NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('income', 'expense', 'transfer')),
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  is_paid BOOLEAN DEFAULT TRUE,
  is_recurring BOOLEAN DEFAULT FALSE,
  recurrence_frequency TEXT CHECK (recurrence_frequency IN ('daily', 'weekly', 'monthly', 'yearly')),
  recurrence_end_date DATE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Validações adicionais
  CONSTRAINT check_credit_card_for_expense CHECK (
    (type = 'expense' AND credit_card_id IS NOT NULL) OR
    (type != 'expense' AND credit_card_id IS NULL) OR
    (type = 'expense' AND credit_card_id IS NULL)
  ),
  CONSTRAINT check_recurrence_end_date CHECK (
    (is_recurring = FALSE AND recurrence_end_date IS NULL) OR
    (is_recurring = TRUE AND recurrence_end_date IS NOT NULL AND recurrence_end_date > date)
  )
);

-- Índices
CREATE INDEX idx_transactions_user_id ON public.transactions(user_id);
CREATE INDEX idx_transactions_wallet_id ON public.transactions(wallet_id);
CREATE INDEX idx_transactions_category_id ON public.transactions(category_id);
CREATE INDEX idx_transactions_credit_card_id ON public.transactions(credit_card_id);
CREATE INDEX idx_transactions_date ON public.transactions(date);
CREATE INDEX idx_transactions_type ON public.transactions(type);

-- Configuração de segurança
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
CREATE POLICY "Usuários podem visualizar suas próprias transações"
  ON public.transactions
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem inserir suas próprias transações"
  ON public.transactions
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar suas próprias transações"
  ON public.transactions
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem excluir suas próprias transações"
  ON public.transactions
  FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger para atualizar o timestamp
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.transactions
  FOR EACH ROW
  EXECUTE FUNCTION public.moddatetime();

-- Função para atualizar o saldo da carteira após inserção/atualização/exclusão de transação
CREATE OR REPLACE FUNCTION update_wallet_balance()
RETURNS TRIGGER AS $$
DECLARE
  amount_change DECIMAL(15, 2);
BEGIN
  -- Para inserções
  IF TG_OP = 'INSERT' THEN
    IF NEW.type = 'income' AND NEW.is_paid THEN
      UPDATE wallets SET balance = balance + NEW.amount WHERE id = NEW.wallet_id;
    ELSIF NEW.type = 'expense' AND NEW.is_paid THEN
      UPDATE wallets SET balance = balance - NEW.amount WHERE id = NEW.wallet_id;
    ELSIF NEW.type = 'transfer' AND NEW.is_paid THEN
      -- Para transferências, precisamos de lógica adicional para identificar a carteira de destino
      -- Esta é uma implementação simplificada
      UPDATE wallets SET balance = balance - NEW.amount WHERE id = NEW.wallet_id;
      -- A carteira de destino seria atualizada em uma lógica separada
    END IF;
    
    -- Atualizar crédito disponível se for despesa com cartão de crédito
    IF NEW.type = 'expense' AND NEW.credit_card_id IS NOT NULL AND NEW.is_paid THEN
      UPDATE credit_cards 
      SET available_credit = available_credit - NEW.amount 
      WHERE id = NEW.credit_card_id;
    END IF;
    
    RETURN NEW;
  
  -- Para atualizações
  ELSIF TG_OP = 'UPDATE' THEN
    -- Calcular a mudança no valor
    IF OLD.type = NEW.type AND OLD.wallet_id = NEW.wallet_id AND OLD.is_paid = NEW.is_paid THEN
      -- Mesmo tipo, mesma carteira, mesmo status de pagamento
      IF NEW.type = 'income' AND NEW.is_paid THEN
        amount_change := NEW.amount - OLD.amount;
        UPDATE wallets SET balance = balance + amount_change WHERE id = NEW.wallet_id;
      ELSIF NEW.type = 'expense' AND NEW.is_paid THEN
        amount_change := OLD.amount - NEW.amount;
        UPDATE wallets SET balance = balance + amount_change WHERE id = NEW.wallet_id;
      END IF;
    ELSE
      -- Casos mais complexos (mudança de tipo, carteira ou status)
      -- Reverter a transação antiga
      IF OLD.type = 'income' AND OLD.is_paid THEN
        UPDATE wallets SET balance = balance - OLD.amount WHERE id = OLD.wallet_id;
      ELSIF OLD.type = 'expense' AND OLD.is_paid THEN
        UPDATE wallets SET balance = balance + OLD.amount WHERE id = OLD.wallet_id;
      END IF;
      
      -- Aplicar a nova transação
      IF NEW.type = 'income' AND NEW.is_paid THEN
        UPDATE wallets SET balance = balance + NEW.amount WHERE id = NEW.wallet_id;
      ELSIF NEW.type = 'expense' AND NEW.is_paid THEN
        UPDATE wallets SET balance = balance - NEW.amount WHERE id = NEW.wallet_id;
      END IF;
    END IF;
    
    -- Atualizar crédito disponível para cartões de crédito
    IF OLD.credit_card_id IS NOT NULL AND OLD.is_paid AND OLD.type = 'expense' THEN
      UPDATE credit_cards 
      SET available_credit = available_credit + OLD.amount 
      WHERE id = OLD.credit_card_id;
    END IF;
    
    IF NEW.credit_card_id IS NOT NULL AND NEW.is_paid AND NEW.type = 'expense' THEN
      UPDATE credit_cards 
      SET available_credit = available_credit - NEW.amount 
      WHERE id = NEW.credit_card_id;
    END IF;
    
    RETURN NEW;
  
  -- Para exclusões
  ELSIF TG_OP = 'DELETE' THEN
    IF OLD.type = 'income' AND OLD.is_paid THEN
      UPDATE wallets SET balance = balance - OLD.amount WHERE id = OLD.wallet_id;
    ELSIF OLD.type = 'expense' AND OLD.is_paid THEN
      UPDATE wallets SET balance = balance + OLD.amount WHERE id = OLD.wallet_id;
    END IF;
    
    -- Atualizar crédito disponível se for despesa com cartão de crédito
    IF OLD.type = 'expense' AND OLD.credit_card_id IS NOT NULL AND OLD.is_paid THEN
      UPDATE credit_cards 
      SET available_credit = available_credit + OLD.amount 
      WHERE id = OLD.credit_card_id;
    END IF;
    
    RETURN OLD;
  END IF;
  
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Triggers para atualizar saldos
CREATE TRIGGER update_wallet_balance_on_insert
  AFTER INSERT ON public.transactions
  FOR EACH ROW
  EXECUTE FUNCTION update_wallet_balance();

CREATE TRIGGER update_wallet_balance_on_update
  AFTER UPDATE ON public.transactions
  FOR EACH ROW
  EXECUTE FUNCTION update_wallet_balance();

CREATE TRIGGER update_wallet_balance_on_delete
  AFTER DELETE ON public.transactions
  FOR EACH ROW
  EXECUTE FUNCTION update_wallet_balance();
