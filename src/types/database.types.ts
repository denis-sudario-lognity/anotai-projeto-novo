export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  public: {
    Tables: {
      wallets: {
        Row: {
          id: string
          user_id: string
          name: string
          type: "conta_corrente" | "cartao_credito" | "investimentos" | "dinheiro"
          balance: number
          currency: string
          created_at: string | null
          updated_at: string | null
        }
        Insert: {
          id?: string
          user_id: string
          name: string
          type: "conta_corrente" | "cartao_credito" | "investimentos" | "dinheiro"
          balance: number
          currency?: string
          created_at?: string | null
          updated_at?: string | null
        }
        Update: {
          id?: string
          user_id?: string
          name?: string
          type?: "conta_corrente" | "cartao_credito" | "investimentos" | "dinheiro"
          balance?: number
          currency?: string
          created_at?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "wallets_user_id_fkey"
            columns: ["user_id"]
            referencedRelation: "users"
            referencedColumns: ["id"]
          }
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      wallet_type: "conta_corrente" | "cartao_credito" | "investimentos" | "dinheiro"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}
