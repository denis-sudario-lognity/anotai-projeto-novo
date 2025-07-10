import { supabase } from "@/lib/supabase";
import { Category } from "@/types";
import { PostgrestError } from "@supabase/supabase-js";

export const categoryService = {
  async getCategories(type?: "income" | "expense"): Promise<{ data: Category[] | null; error: PostgrestError | null }> {
    let query
