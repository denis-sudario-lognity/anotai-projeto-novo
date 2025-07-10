import { supabase } from "@/lib/supabase";
import { Wallet } from "@/types";
import { PostgrestError } from "@supabase/supabase-js";

export const walletService = {
  async getWallets(): Promise<{ data: Wallet[] | null; error: PostgrestError | null }> {
    return await supabase
      .from("wallets")
      .select("*")
      .order("is_default", { ascending: false })
      .order("name");
  },

  async getWalletById(id: string): Promise<{ data: Wallet | null; error: PostgrestError | null }> {
    return await supabase
      .from("wallets")
      .select("*")
      .eq("id", id)
      .single();
  },

  async createWallet(wallet: Omit<Wallet, "id" | "created_at">): Promise<{ data: Wallet | null; error: PostgrestError | null }> {
    return await supabase
      .from("wallets")
      .insert(wallet)
      .select()
      .single();
  },

  async updateWallet(id: string, wallet: Partial<Wallet>): Promise<{ data: Wallet | null; error: PostgrestError | null }> {
    return await supabase
      .from("wallets")
      .update(wallet)
      .eq("id", id)
      .select()
      .single();
  },

  async deleteWallet(id: string): Promise<{ error: PostgrestError | null }> {
    return await supabase
      .from("wallets")
      .delete()
      .eq("id", id);
  }
};
