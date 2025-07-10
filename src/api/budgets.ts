import { supabase } from '@/lib/supabase';
import { CreateBudgetSchema } from '@/lib/validators';
import { Budget } from '@/types';

type BudgetWithCategory = Budget & {
  categories: { name: string } | null;
};

export async function getBudgets() {
  const { data, error } = await supabase
    .from('budgets')
    .select('*, categories(name)');

  if (error) {
    console.error('Error fetching budgets:', error);
    throw new Error('Não foi possível carregar os orçamentos.');
  }

  // TODO: The 'spent' amount should be calculated from transactions.
  // For now, we'll mock it.
  return data.map((budget: BudgetWithCategory) => ({
    ...budget,
    category_name: budget.categories?.name ?? 'Sem Categoria',
    spent: Math.random() * budget.amount, // Mocked spent amount
  }));
}

export async function createBudget(budgetData: CreateBudgetSchema) {
  const { data: { session } } = await supabase.auth.getSession();
  if (!session) throw new Error('Usuário não autenticado.');
  
  const { user } = session;

  const { data, error } = await supabase
    .from('budgets')
    .insert([{ ...budgetData, user_id: user.id }])
    .select()
    .single();

  if (error) {
    console.error('Error creating budget:', error);
    throw new Error('Não foi possível criar o orçamento.');
  }

  return data;
}
