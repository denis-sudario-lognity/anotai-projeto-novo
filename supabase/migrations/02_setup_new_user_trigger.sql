/*
  # Gatilho para Sincronização de Novos Usuários

  Este script cria a lógica para popular automaticamente a tabela `profiles` quando um novo usuário se cadastra no sistema (`auth.users`).

  1. Novas Funções
     - `handle_new_user`: Insere um novo registro na tabela `profiles` com os dados do novo usuário.

  2. Triggers
     - `on_auth_user_created`: Dispara a função `handle_new_user` após a inserção de um novo usuário em `auth.users`.
*/

-- 1. Função de Sincronização
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Trigger de Criação de Usuário
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();