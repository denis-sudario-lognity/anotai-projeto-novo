import { supabase } from "@/lib/supabase";
import { Transaction, TransactionFilters, TransactionFormValues } from "@/types";
import { PostgrestError } from "@supabase/supabase-js";

export const transactionService = {
  async getTransactions(filters?: TransactionFilters): Promise<{ data: Transaction[] | null; error: PostgrestError | null }> {
    let query = supabase
      .from("transactions")
      .select(`
        *,
        wallet:wallets(*),
        category:categories(*),
        credit_card:credit_cards(*)
      `)
      .order("date", { ascending: false });

    // Aplicar filtros se fornecidos
    if (filters) {
      if (filters.startDate) {
        query = query.gte("date", filters.startDate);
      }
      if (filters.endDate) {
        query = query.lte("date", filters.endDate);
      }
      if (filters.type && filters.type !== "all") {
        query = query.eq("type", filters.type);
      }
      if (filters.walletId) {
        query = query.eq("wallet_id", filters.walletId);
      }
      if (filters.categoryId) {
        query = query.eq("category_id", filters.categoryId);
      }
      if (filters.creditCardId) {
        query = query.eq("credit_card_id", filters.creditCardId);
      }
      if (filters.isPaid !== undefined) {
        query = query.eq("is_paid", filters.isPaid);
      }
      if (filters.search) {
        query = query.ilike("description", `%${filters.search}%`);
      }
      if (filters.minAmount !== undefined) {
        query = query.gte("amount", filters.minAmount);
      }
      if (filters.maxAmount !== undefined) {
        query = query.lte("amount", filters.maxAmount);
      }
    }

    return await query;
  },

  async getTransactionById(id: string): Promise<{ data: Transaction | null; error: PostgrestError | null }> {
    return await supabase
      .from("transactions")
      .select(`
        *,
        wallet:wallets(*),
        category:categories(*),
        credit_card:credit_cards(*)
      `)
      .eq("id", id)
      .single();
  },

  async createTransaction(transaction: TransactionFormValues): Promise<{ data: Transaction | null; error: PostgrestError | null }> {
    // Converter datas para o formato ISO
    const formattedTransaction = {
      ...transaction,
      date: transaction.date.toISOString().split("T")[0],
      recurrence_end_date: transaction.recurrence_end_date
        ? transaction.recurrence_end_date.toISOString().split("T")[0]
        : null,
    };

    return await supabase
      .from("transactions")
      .insert(formattedTransaction)
      .select()
      .single();
  },

  async updateTransaction(id: string, transaction: TransactionFormValues): Promise<{ data: Transaction | null; error: PostgrestError | null }> {
    // Converter datas para o formato ISO
    const formattedTransaction = {
      ...transaction,
      date: transaction.date.toISOString().split("T")[0],
      recurrence_end_date: transaction.recurrence_end_date
        ? transaction.recurrence_end_date.toISOString().split("T")[0]
        : null,
    };

    return await supabase
      .from("transactions")
      .update(formattedTransaction)
      .eq("id", id)
      .select()
      .single();
  },

  async deleteTransaction(id: string): Promise<{ error: PostgrestError | null }> {
    return await supabase
      .from("transactions")
      .delete()
      .eq("id", id);
  },

  async getMonthlySummary(year?: number, month?: number): Promise<{ 
    data: { month: number; year: number; total_income: number; total_expense: number; balance: number }[] | null; 
    error: PostgrestError | null 
  }> {
    return await supabase
      .rpc("get_monthly_summary", {
        year_param: year,
        month_param: month
      });
  },

  async getCategorySummary(
    startDate?: string,
    endDate?: string,
    type: "income" | "expense" = "expense"
  ): Promise<{ 
    data: { 
      category_id: string; 
      category_name: string; 
      category_color: string; 
      category_icon: string; 
      total_amount: number; 
      percentage: number 
    }[] | null; 
    error: PostgrestError | null 
  }> {
    return await supabase
      .rpc("get_category_summary", {
        start_date_param: startDate,
        end_date_param: endDate,
        transaction_type: type
      });
  },

  async getCashFlow(
    startDate?: string,
    endDate?: string
  ): Promise<{ 
    data: { date: string; income: number; expense: number; balance: number }[] | null; 
    error: PostgrestError | null 
  }> {
    return await supabase
      .rpc("get_cash_flow", {
        start_date_param: startDate,
        end_date_param: endDate
      });
  }
};
