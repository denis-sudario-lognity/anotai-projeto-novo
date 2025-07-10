/*
  # Configuração Inicial e Funções Utilitárias

  Este script prepara o banco de dados com extensões essenciais e funções de utilidade que serão usadas em outras tabelas.

  1. Extensões
     - `uuid-ossp`: Para geração de UUIDs.
     - `pg_trgm`: Para funcionalidades de busca em texto.

  2. Novas Funções
     - `moddatetime`: Uma função de trigger para atualizar automaticamente o campo `updated_at` em qualquer tabela que a utilize.
*/

-- 1. Extensões
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS "pg_trgm" WITH SCHEMA extensions;

-- 2. Funções Utilitárias
CREATE OR REPLACE FUNCTION public.moddatetime()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;