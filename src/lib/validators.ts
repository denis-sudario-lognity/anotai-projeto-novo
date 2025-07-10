import { z } from 'zod';

export const CreateBudgetSchema = z.object({
  name: z.string().min(1, 'Nome é obrigatório'),
  amount: z.coerce.number().min(1, 'Valor deve ser maior que zero'),
  category_id: z.string().uuid('Categoria inválida'),
  description: z.string().optional(),
});

export type CreateBudgetSchema = z.infer<typeof CreateBudgetSchema>;
