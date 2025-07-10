/*
  # Criação da Tabela de Categorias (Categories)

  Este script cria a tabela `categories` para classificar transações. Inclui categorias padrão do sistema e permite que usuários criem as suas.

  1. Nova Tabela
     - `categories`: Armazena categorias de receita e despesa.
       - `user_id`: Referência ao usuário (pode ser nulo para categorias do sistema).
       - `type`: 'income' (receita) ou 'expense' (despesa).
       - `is_system`: `TRUE` para categorias padrão.

  2. Segurança
     - Habilita RLS.
     - Políticas permitem que usuários vejam categorias do sistema e gerenciem as suas próprias.

  3. Dados Iniciais
     - Insere um conjunto de categorias padrão de receita e despesa.
*/

-- 1. Criação da Tabela
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

-- Índices
CREATE INDEX IF NOT EXISTS idx_categories_user_id ON public.categories(user_id);
CREATE INDEX IF NOT EXISTS idx_categories_type ON public.categories(type);

-- 2. Segurança
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

-- Trigger
DROP TRIGGER IF EXISTS set_updated_at ON public.categories;
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.categories
  FOR EACH ROW
  EXECUTE FUNCTION public.moddatetime();

-- 3. Dados Iniciais (Categorias do Sistema)
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