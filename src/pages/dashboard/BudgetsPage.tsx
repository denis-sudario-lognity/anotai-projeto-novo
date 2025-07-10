import { useQuery } from "@tanstack/react-query";
import Header from "@/components/shared/Header";
import CreateBudgetModal from "@/components/budgets/CreateBudgetModal";
import { getBudgets } from "@/api/budgets";
import BudgetList from "@/components/budgets/BudgetList";
import { Skeleton } from "@/components/ui/skeleton";

function EmptyState() {
  return (
    <div className="flex flex-1 items-center justify-center rounded-lg border border-dashed shadow-sm">
      <div className="flex flex-col items-center gap-1 text-center">
        <h3 className="text-2xl font-bold tracking-tight">
          Você ainda não tem orçamentos
        </h3>
        <p className="text-sm text-muted-foreground">
          Comece a criar orçamentos para controlar seus gastos por categoria.
        </p>
        <div className="mt-4">
          <CreateBudgetModal />
        </div>
      </div>
    </div>
  );
}

function LoadingState() {
  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      {Array.from({ length: 3 }).map((_, i) => (
        <div key={i} className="flex flex-col space-y-3">
          <Skeleton className="h-[125px] w-full rounded-xl" />
          <div className="space-y-2">
            <Skeleton className="h-4 w-[250px]" />
            <Skeleton className="h-4 w-[200px]" />
          </div>
        </div>
      ))}
    </div>
  )
}

export default function BudgetsPage() {
  const { data: budgets, isLoading, isError } = useQuery({
    queryKey: ['budgets'],
    queryFn: getBudgets,
  });

  return (
    <>
      <Header title="Orçamentos" action={<CreateBudgetModal />} />
      {isLoading ? (
        <LoadingState />
      ) : isError ? (
        <div className="text-red-500">Erro ao carregar os orçamentos.</div>
      ) : budgets && budgets.length > 0 ? (
        <BudgetList budgets={budgets} />
      ) : (
        <EmptyState />
      )}
    </>
  );
}
