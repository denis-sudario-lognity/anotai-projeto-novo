/*
  # Criação de funções utilitárias
  
  1. Funções
     - `moddatetime()`: Atualiza automaticamente o campo updated_at
     - `get_monthly_summary()`: Obtém um resumo mensal de receitas e despesas
     - `get_category_summary()`: Obtém um resumo de gastos por categoria
  
  2. Segurança
     - Todas as funções são definidas com SECURITY DEFINER para garantir acesso adequado aos dados
*/

-- Função para atualizar automaticamente o campo updated_at
CREATE OR REPLACE FUNCTION public.mod
