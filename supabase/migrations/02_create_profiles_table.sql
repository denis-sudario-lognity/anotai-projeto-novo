/*
  # Criação da tabela de perfis
  
  1. Nova Tabela
     - `profiles`: Armazena informações de perfil dos usuários
       - `id` (uuid, chave primária)
       - `email` (texto, único)
       - `full_name` (texto)
       - `avatar_url` (texto)
       - `created_at` (timestamp)
       - `updated_at` (timestamp)
  
  2. Segurança
     - Habilita RLS na tabela `profiles`
     - Adiciona políticas para usuários autenticados
*/

-- Criação da tabela de perfis
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Configuração de segurança
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
CREATE POLICY "Usuários podem visualizar seus próprios perfis"
  ON public.profiles
  FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Usuários podem atualizar seus próprios perfis"
  ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id);

-- Trigger para atualizar o timestamp
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.moddatetime();
