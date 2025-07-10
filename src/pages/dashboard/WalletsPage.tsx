import Header from "@/components/shared/Header";

export default function WalletsPage() {
  return (
    <>
      <Header title="Carteiras" />
      <div className="flex flex-1 items-center justify-center rounded-lg border border-dashed shadow-sm">
        <div className="flex flex-col items-center gap-1 text-center">
          <h3 className="text-2xl font-bold tracking-tight">
            A gestão de carteiras está chegando!
          </h3>
          <p className="text-sm text-muted-foreground">
            Você poderá adicionar e gerenciar seus cartões de crédito e contas bancárias aqui.
          </p>
        </div>
      </div>
    </>
  )
}
