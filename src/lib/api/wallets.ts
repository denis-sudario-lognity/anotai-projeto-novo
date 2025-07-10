import { supabase } from "@/lib/supabase";
import { Database } from "@/types/database.types";

export type Wallet = Database['public']['Tables']['wallets']['Row'];
export type NewWallet = Database['public']['Tables']['wallets']['Insert'];
// The payload for creating a new wallet, without the user_id which will be added by the API.
export type NewWalletPayload = Omit<NewWallet, 'user_id'>;

export async function getWallets(): Promise<Wallet[]> {
  const { data: sessionData, error: sessionError } = await supabase.auth.getSession();
  if (sessionError || !sessionData.session) {
    throw new Error("User not authenticated");
  }

  const { data, error } = await supabase
    .from("wallets")
    .select("*")
    .order("created_at", { ascending: true });

  if (error) {
    console.error("Error fetching wallets:", error);
    throw new Error(error.message);
  }

  return data || [];
}

export async function addWallet(wallet: NewWalletPayload): Promise<Wallet> {
  const { data: sessionData, error: sessionError } = await supabase.auth.getSession();
  if (sessionError || !sessionData.session) {
    throw new Error("User not authenticated");
  }
  const userId = sessionData.session.user.id;

  const { data, error } = await supabase
    .from("wallets")
    .insert({ ...wallet, user_id: userId })
    .select()
    .single();

  if (error) {
    console.error("Error adding wallet:", error);
    throw new Error(error.message);
  }

  return data;
}
