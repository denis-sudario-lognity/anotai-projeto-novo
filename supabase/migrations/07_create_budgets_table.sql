/*
  # Criação da tabela de orçamentos
  
  1. Nova Tabela
     - `budgets`: Armazena orçamentos para categorias específicas
       - `id` (uuid, chave primária)
       - `user_id` (uuid, referência a profiles.id)
       - `category_id` (uuid, referência a categories.id)
       - `name` (texto)
       - `amount` (decimal)
       - `period` (texto: 'monthly', 'yearly')
       - `start_date` (data)
       - `end_date` (data, opcional)
       - `created_at` (timestamp)
       - `updated_at` (timestamp)
  
  2. Segurança
     - Habilita RLS na tabela `budgets`
     - Adiciona políticas para usuários autenticados
*/

-- Criação da tabela de orçamentos
CREATE TABLE IF NOT EXISTS public.budgets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  category_id UUID REFERENCES public.categories(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
  period TEXT NOT NULL CHECK (period IN ('monthly', 'yearly')),
  start_date DATE NOT NULL DEFAULT CURRENT_DATE,
  end_date DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Validações adicionais
  CONSTRAINT check_end_date CHECK (
    end_date IS NULL OR end_date >= start_date
  )
);

-- Índices
CREATE INDEX idx_budgets_user_id ON public.budgets(user_id);
CREATE INDEX idx_budgets_category_id ON public.budgets(category_id);
CREATE INDEX idx_budgets_period ON public.budgets(period);

-- Configuração de segurança
ALTER TABLE public.budgets ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
CREATE POLICY "Usuários podem visualizar seus próprios orçamentos"
  ON public.budgets
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem inserir seus próprios orçamentos"
  ON public.budgets
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seus próprios orçamentos"
  ON public.budgets
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem excluir seus próprios orçamentos"
  ON public.budgets
  FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger para atualizar o timestamp
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.budgets
  FOR EACH ROW
  EXECUTE FUNCTION public.moddatetime();

-- Função para calcular o progresso do orçamento
CREATE OR REPLACE FUNCTION get_budget_progress(budget_id UUID)
RETURNS TABLE (
  total_spent DECIMAL(15, 2),
  budget_amount DECIMAL(15, 2),
  percentage DECIMAL(5, 2)
) AS $$
DECLARE
  v_budget RECORD;
  v_start_date DATE;
  v_end_date DATE;
  v_category_id UUID;
  v_user_id UUID;
BEGIN
  -- Obter informações do orçamento
  SELECT b.*, u.id INTO v_budget, v_user_id
  FROM budgets b
  JOIN auth.users u ON b.user_id = u.id
  WHERE b.id = budget_id AND b.user_id = auth.uid();
  
  IF v_budget IS NULL THEN
    RETURN;
  END IF;
  
  v_category_id := v_budget.category_id;
  
  -- Determinar o período de datas para o cálculo
  IF v_budget.period = 'monthly' THEN
    v_start_date := DATE_TRUNC('month', CURRENT_DATE);
    v_end_date := (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day')::DATE;
  ELSIF v_budget.period = 'yearly' THEN
    v_start_date := DATE_TRUNC('year', CURRENT_DATE);
    v_end_date := (DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '1 year' - INTERVAL '1 day')::DATE;
  ELSE
    v_start_date := v_budget.start_date;
    v_end_date := COALESCE(v_budget.end_date, CURRENT_DATE);
  END IF;
  
  -- Se o orçamento tiver datas específicas, usá-las
  IF v_budget.start_date IS NOT NULL THEN
    v_start_date := v_budget.start_date;
  END IF;
  
  IF v_budget.end_date IS NOT NULL THEN
    v_end_date := v_budget.end_date;
  END IF;
  
  -- Calcular o total gasto
  SELECT COALESCE(SUM(amount), 0) INTO total_spent
  FROM transactions
  WHERE user_id = v_user_id
    AND type = 'expense'
    AND date BETWEEN v_start_date AND v_end_date
    AND (v_category_id IS NULL OR category_id = v_category_id);
  
  -- Definir o valor do orçamento
  budget_amount := v_budget.amount;
  
  -- Calcular a porcentagem
  IF budget_amount > 0 THEN
    percentage := (total_spent / budget_amount) * 100;
  ELSE
    percentage := 0;
  END IF;
  
  RETURN NEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
