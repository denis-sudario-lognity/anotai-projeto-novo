import { Budget } from '@/types';
import BudgetCard from './BudgetCard';

interface BudgetListProps {
  budgets: (Budget & { spent: number; category_name: string })[];
}

export default function BudgetList({ budgets }: BudgetListProps) {
  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      {budgets.map((budget) => (
        <BudgetCard key={budget.id} budget={budget} />
      ))}
    </div>
  );
}
