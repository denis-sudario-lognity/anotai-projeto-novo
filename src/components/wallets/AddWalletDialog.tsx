import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { addWallet, NewWalletPayload } from "@/lib/api/wallets";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { useToast } from "@/hooks/use-toast";

const walletFormSchema = z.object({
  name: z.string().min(2, { message: "O nome deve ter pelo menos 2 caracteres." }),
  type: z.enum(["conta_corrente", "cartao_credito", "investimentos", "dinheiro"], {
    required_error: "Por favor, selecione um tipo de carteira.",
  }),
  balance: z.coerce.number().min(0, { message: "O saldo inicial não pode ser negativo." }),
});

type WalletFormValues = z.infer<typeof walletFormSchema>;

interface AddWalletDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export default function AddWalletDialog({ open, onOpenChange }: AddWalletDialogProps) {
  const { toast } = useToast();
  const queryClient = useQueryClient();

  const form = useForm<WalletFormValues>({
    resolver: zodResolver(walletFormSchema),
    defaultValues: {
      name: "",
      balance: 0,
    },
  });

  const addWalletMutation = useMutation({
    mutationFn: (newWallet: NewWalletPayload) => addWallet(newWallet),
    onSuccess: () => {
      toast({
        title: "Sucesso!",
        description: "Sua nova carteira foi adicionada.",
      });
      queryClient.invalidateQueries({ queryKey: ["wallets"] });
      onOpenChange(false);
    },
    onError: (error) => {
      toast({
        variant: "destructive",
        title: "Erro ao adicionar carteira",
        description: error.message,
      });
    },
  });

  function onSubmit(values: WalletFormValues) {
    const newWallet: NewWalletPayload = {
        name: values.name,
        type: values.type,
        balance: values.balance,
    };
    addWalletMutation.mutate(newWallet);
  }

  const handleOpenChange = (isOpen: boolean) => {
    if (!isOpen) {
      form.reset();
    }
    onOpenChange(isOpen);
  };

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>Adicionar Nova Carteira</DialogTitle>
          <DialogDescription>
            Preencha os detalhes da sua nova carteira.
          </DialogDescription>
        </DialogHeader>
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
            <FormField
              control={form.control}
              name="name"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Nome da Carteira</FormLabel>
                  <FormControl>
                    <Input placeholder="Ex: Conta Principal" {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="type"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Tipo</FormLabel>
                  <Select onValueChange={field.onChange} defaultValue={field.value}>
                    <FormControl>
                      <SelectTrigger>
                        <SelectValue placeholder="Selecione o tipo de carteira" />
                      </SelectTrigger>
                    </FormControl>
                    <SelectContent>
                      <SelectItem value="conta_corrente">Conta Corrente</SelectItem>
                      <SelectItem value="cartao_credito">Cartão de Crédito</SelectItem>
                      <SelectItem value="investimentos">Investimentos</SelectItem>
                      <SelectItem value="dinheiro">Dinheiro</SelectItem>
                    </SelectContent>
                  </Select>
                  <FormMessage />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="balance"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Saldo Inicial</FormLabel>
                  <FormControl>
                    <Input type="number" placeholder="0.00" {...field} step="0.01" />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            <DialogFooter>
              <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
                Cancelar
              </Button>
              <Button type="submit" disabled={addWalletMutation.isPending}>
                {addWalletMutation.isPending ? "Salvando..." : "Salvar"}
              </Button>
            </DialogFooter>
          </form>
        </Form>
      </DialogContent>
    </Dialog>
  );
}
