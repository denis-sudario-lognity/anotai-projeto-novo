import Header from "@/components/shared/Header";

export default function TransactionsPage() {
  return (
    <>
      <Header title="Transactions" />
      <div className="flex flex-1 items-center justify-center rounded-lg border border-dashed shadow-sm">
        <div className="flex flex-col items-center gap-1 text-center">
          <h3 className="text-2xl font-bold tracking-tight">
            Transaction history coming soon!
          </h3>
          <p className="text-sm text-muted-foreground">
            You will be able to view and categorize all your transactions here.
          </p>
        </div>
      </div>
    </>
  )
}
