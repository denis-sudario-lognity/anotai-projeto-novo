import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { getWallets } from "@/lib/api/wallets";
import Header from "@/components/shared/Header";
import { Button } from "@/components/ui/button";
import { PlusCircle, Landmark, CreditCard, Briefcase, DollarSign } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import AddWalletDialog from "@/components/wallets/AddWalletDialog";

const walletIcons = {
  conta_corrente: <Landmark className="h-6 w-6 text-muted-foreground" />,
  cartao_credito: <CreditCard className="h-6 w-6 text-muted-foreground" />,
  investimentos: <Briefcase className="h-6 w-6 text-muted-foreground" />,
  dinheiro: <DollarSign className="h-6 w-6 text-muted-foreground" />,
};

const walletTypeNames = {
  conta_corrente: "Conta Corrente",
  cartao_credito: "Cartão de Crédito",
  investimentos: "Investimentos",
  dinheiro: "Dinheiro",
};

export default function WalletsPage() {
  const [isAddWalletOpen, setAddWalletOpen] = useState(false);

  const { data: wallets, isLoading, isError } = useQuery({
    queryKey: ["wallets"],
    queryFn: getWallets,
  });

  const renderSkeleton = () => (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      {[...Array(3)].map((_, i) => (
        <Card key={i}>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <Skeleton className="h-6 w-24" />
            <Skeleton className="h-6 w-6 rounded-full" />
          </CardHeader>
          <CardContent>
            <Skeleton className="h-8 w-32" />
            <Skeleton className="h-4 w-20 mt-1" />
          </CardContent>
        </Card>
      ))}
    </div>
  );

  const renderEmptyState = () => (
    <div className="flex flex-1 items-center justify-center rounded-lg border border-dashed shadow-sm h-full">
      <div className="flex flex-col items-center gap-2 text-center">
        <h3 className="text-2xl font-bold tracking-tight">
          Nenhuma carteira encontrada
        </h3>
        <p className="text-sm text-muted-foreground mb-4">
          Comece adicionando sua primeira carteira para organizar suas finanças.
        </p>
        <Button onClick={() => setAddWalletOpen(true)}>
          <PlusCircle className="mr-2 h-4 w-4" />
          Adicionar Carteira
        </Button>
      </div>
    </div>
  );

  return (
    <>
      <Header title="Minhas Carteiras">
        <Button onClick={() => setAddWalletOpen(true)}>
          <PlusCircle className="mr-2 h-4 w-4" />
          Adicionar Carteira
        </Button>
      </Header>
      <div className="flex-1 space-y-4">
        {isLoading ? (
          renderSkeleton()
        ) : isError ? (
          <div className="text-red-500">Erro ao carregar as carteiras.</div>
        ) : wallets && wallets.length > 0 ? (
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            {wallets.map((wallet) => (
              <Card key={wallet.id}>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">{wallet.name}</CardTitle>
                  {walletIcons[wallet.type]}
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">
                    {new Intl.NumberFormat("pt-BR", {
                      style: "currency",
                      currency: wallet.currency,
                    }).format(wallet.balance)}
                  </div>
                  <p className="text-xs text-muted-foreground">
                    {walletTypeNames[wallet.type]}
                  </p>
                </CardContent>
              </Card>
            ))}
          </div>
        ) : (
          renderEmptyState()
        )}
      </div>
      <AddWalletDialog open={isAddWalletOpen} onOpenChange={setAddWalletOpen} />
    </>
  );
}
