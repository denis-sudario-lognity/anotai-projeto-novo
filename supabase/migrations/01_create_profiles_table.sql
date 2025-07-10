/*
  # Criação da Tabela de Perfis (Profiles)

  Este script cria a tabela `profiles` para armazenar informações adicionais dos usuários, vinculadas à tabela `auth.users`.

  1. Nova Tabela
     - `profiles`: Armazena dados de perfil.
       - `id`: Chave primária, referenciando `auth.users.id`.
       - `email`: Email do usuário, único.
       - `full_name`: Nome completo.
       - `avatar_url`: URL para o avatar do usuário.
       - `created_at`, `updated_at`: Timestamps de criação e atualização.

  2. Segurança
     - Habilita Row Level Security (RLS) na tabela.
     - Política de SELECT: Permite que usuários visualizem seus próprios perfis.
     - Política de UPDATE: Permite que usuários atualizem seus próprios perfis.

  3. Triggers
     - `set_updated_at`: Dispara a função `moddatetime()` para atualizar `updated_at` em cada modificação.
*/

-- 1. Criação da Tabela
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Segurança
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Usuários podem visualizar seus próprios perfis" ON public.profiles;
CREATE POLICY "Usuários podem visualizar seus próprios perfis"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "Usuários podem atualizar seus próprios perfis" ON public.profiles;
CREATE POLICY "Usuários podem atualizar seus próprios perfis"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- 3. Triggers
DROP TRIGGER IF EXISTS set_updated_at ON public.profiles;
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.moddatetime();