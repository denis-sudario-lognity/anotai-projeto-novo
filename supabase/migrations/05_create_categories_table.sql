/*
  # Criação da tabela de categorias
  
  1. Nova Tabela
     - `categories`: Armazena categorias para transações financeiras
       - `id` (uuid, chave primária)
       - `user_id` (uuid, referência a profiles.id)
       - `name` (texto)
       - `description` (texto)
       - `color` (texto)
       - `icon` (texto)
       - `type` (texto: 'income', 'expense')
       - `is_system` (booleano)
       - `created_at` (timestamp)
       - `updated_at` (timestamp)
  
  2. Segurança
     - Habilita RLS na tabela `categories`
     - Adiciona políticas para usuários autenticados
*/

-- Criação da tabela de categorias
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
CREATE INDEX idx_categories_user_id ON public.categories(user_id);
CREATE INDEX idx_categories_type ON public.categories(type);

-- Configuração de segurança
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
CREATE POLICY "Usuários podem visualizar categorias do sistema e suas próprias"
  ON public.categories
  FOR SELECT
  USING (is_system OR auth.uid() = user_id);

CREATE POLICY "Usuários podem inserir suas próprias categorias"
  ON public.categories
  FOR INSERT
  WITH CHECK (auth.uid() = user_id AND NOT is_system);

CREATE POLICY "Usuários podem atualizar suas próprias categorias"
  ON public.categories
  FOR UPDATE
  USING (auth.uid() = user_id AND NOT is_system);

CREATE POLICY "Usuários podem excluir suas próprias categorias"
  ON public.categories
  FOR DELETE
  USING (auth.uid() = user_id AND NOT is_system);

-- Trigger para atualizar o timestamp
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.categories
  FOR EACH ROW
  EXECUTE FUNCTION public.moddatetime();

-- Inserir categorias padrão do sistema
INSERT INTO public.categories (id, name, description, color, icon, type, is_system)
VALUES
  -- Categorias de Receita
  (uuid_generate_v4(), NULL, 'Salário', 'Rendimentos do trabalho', '#10B981', 'briefcase', 'income', TRUE),
  (uuid_generate_v4(), NULL, 'Investimentos', 'Rendimentos de investimentos', '#6366F1', 'trending-up', 'income', TRUE),
  (uuid_generate_v4(), NULL, 'Freelance', 'Trabalhos extras', '#F59E0B', 'code', 'income', TRUE),
  (uuid_generate_v4(), NULL, 'Presentes', 'Dinheiro recebido como presente', '#EC4899', 'gift', 'income', TRUE),
  (uuid_generate_v4(), NULL, 'Outros', 'Outras receitas', '#6B7280', 'plus-circle', 'income', TRUE),
  
  -- Categorias de Despesa
  (uuid_generate_v4(), NULL, 'Alimentação', 'Restaurantes, mercado, delivery', '#EF4444', 'utensils', 'expense', TRUE),
  (uuid_generate_v4(), NULL, 'Moradia', 'Aluguel, condomínio, IPTU', '#8B5CF6', 'home', 'expense', TRUE),
  (uuid_generate_v4(), NULL, 'Transporte', 'Combustível, transporte público, apps', '#F97316', 'car', 'expense', TRUE),
  (uuid_generate_v4(), NULL, 'Lazer', 'Cinema, viagens, hobbies', '#06B6D4', 'film', 'expense', TRUE),
  (uuid_generate_v4(), NULL, 'Saúde', 'Consultas, medicamentos, plano de saúde', '#10B981', 'activity', 'expense', TRUE),
  (uuid_generate_v4(), NULL, 'Educação', 'Cursos, livros, material escolar', '#3B82F6', 'book', 'expense', TRUE),
  (uuid_generate_v4(), NULL, 'Compras', 'Roupas, eletrônicos, presentes', '#EC4899', 'shopping-bag', 'expense', TRUE),
  (uuid_generate_v4(), NULL, 'Contas', 'Água, luz, internet, telefone', '#F59E0B', 'file-text', 'expense', TRUE),
  (uuid_generate_v4(), NULL, 'Outros', 'Outras despesas', '#6B7280', 'more-horizontal', 'expense', TRUE);
