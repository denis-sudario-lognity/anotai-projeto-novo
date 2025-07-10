import { supabase } from '@/lib/supabase';
import { Category } from '@/types';

export async function getCategories(): Promise<Category[]> {
  const { data, error } = await supabase
    .from('categories')
    .select('*')
    .order('name');

  if (error) {
    console.error('Error fetching categories:', error);
    throw new Error('Não foi possível carregar as categorias.');
  }

  return data || [];
}

export async function createCategory(name: string) {
  const { data: { session } } = await supabase.auth.getSession();
  if (!session) throw new Error('Usuário não autenticado.');
  
  const { user } = session;

  const { data, error } = await supabase
    .from('categories')
    .insert([{ name, user_id: user.id }])
    .select()
    .single();

  if (error) {
    console.error('Error creating category:', error);
    throw new Error('Não foi possível criar a categoria.');
  }

  return data;
}
