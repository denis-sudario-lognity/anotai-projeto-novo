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
      budgets: {
        Row: {
          id: string
          created_at: string
          name: string
          amount: number
          user_id: string
          category_id: string
          workspace_id: string | null
        }
        Insert: {
          id?: string
          created_at?: string
          name: string
          amount: number
          user_id: string
          category_id: string
          workspace_id?: string | null
        }
        Update: {
          id?: string
          created_at?: string
          name?: string
          amount?: number
          user_id?: string
          category_id?: string
          workspace_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "budgets_category_id_fkey"
            columns: ["category_id"]
            referencedRelation: "categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "budgets_user_id_fkey"
            columns: ["user_id"]
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "budgets_workspace_id_fkey"
            columns: ["workspace_id"]
            referencedRelation: "workspaces"
            referencedColumns: ["id"]
          }
        ]
      }
      categories: {
        Row: {
          id: string
          created_at: string
          name: string
          user_id: string | null
          type: "income" | "expense"
          icon: string | null
          color: string | null
          is_system: boolean
          workspace_id: string | null
        }
        Insert: {
          id?: string
          created_at?: string
          name: string
          user_id?: string | null
          type?: "income" | "expense"
          icon?: string | null
          color?: string | null
          is_system?: boolean
          workspace_id?: string | null
        }
        Update: {
          id?: string
          created_at?: string
          name?: string
          user_id?: string | null
          type?: "income" | "expense"
          icon?: string | null
          color?: string | null
          is_system?: boolean
          workspace_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "categories_user_id_fkey"
            columns: ["user_id"]
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "categories_workspace_id_fkey"
            columns: ["workspace_id"]
            referencedRelation: "workspaces"
            referencedColumns: ["id"]
          }
        ]
      }
      credit_cards: {
        Row: {
          id: string
          created_at: string
          name: string
          user_id: string
          limit: number
          available_credit: number
          closing_day: number
          due_day: number
          color: string | null
          wallet_id: string
          workspace_id: string | null
        }
        Insert: {
          id?: string
          created_at?: string
          name: string
          user_id: string
          limit: number
          available_credit?: number
          closing_day: number
          due_day: number
          color?: string | null
          wallet_id: string
          workspace_id?: string | null
        }
        Update: {
          id?: string
          created_at?: string
          name?: string
          user_id?: string
          limit?: number
          available_credit?: number
          closing_day?: number
          due_day?: number
          color?: string | null
          wallet_id?: string
          workspace_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "credit_cards_user_id_fkey"
            columns: ["user_id"]
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "credit_cards_wallet_id_fkey"
            columns: ["wallet_id"]
            referencedRelation: "wallets"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "credit_cards_workspace_id_fkey"
            columns: ["workspace_id"]
            referencedRelation: "workspaces"
            referencedColumns: ["id"]
          }
        ]
      }
      notifications: {
        Row: {
          id: string
          user_id: string
          title: string
          message: string
          type: string
          link: string | null
          is_read: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          title: string
          message: string
          type: string
          link?: string | null
          is_read?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          title?: string
          message?: string
          type?: string
          link?: string | null
          is_read?: boolean
          created_at?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "notifications_user_id_fkey"
            columns: ["user_id"]
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          }
        ]
      }
      profiles: {
        Row: {
          id: string
          created_at: string
          email: string
          name: string | null
          avatar_url: string | null
        }
        Insert: {
          id: string
          created_at?: string
          email: string
          name?: string | null
          avatar_url?: string | null
        }
        Update: {
          id?: string
          created_at?: string
          email?: string
          name?: string | null
          avatar_url?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "profiles_id_fkey"
            columns: ["id"]
            referencedRelation: "users"
            referencedColumns: ["id"]
          }
        ]
      }
      subscription_plans: {
        Row: {
          id: string
          name: string
          description: string | null
          price: number
          interval: string
          features: Json
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          description?: string | null
          price: number
          interval: string
          features?: Json
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          description?: string | null
          price?: number
          interval?: string
          features?: Json
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Relationships: []
      }
      subscriptions: {
        Row: {
          id: string
          user_id: string
          plan_id: string
          status: string
          current_period_start: string
          current_period_end: string
          cancel_at_period_end: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          plan_id: string
          status: string
          current_period_start: string
          current_period_end: string
          cancel_at_period_end?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          plan_id?: string
          status?: string
          current_period_start?: string
          current_period_end?: string
          cancel_at_period_end?: boolean
          created_at?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "subscriptions_plan_id_fkey"
            columns: ["plan_id"]
            referencedRelation: "subscription_plans"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "subscriptions_user_id_fkey"
            columns: ["user_id"]
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          }
        ]
      }
      transactions: {
        Row: {
          id: string
          user_id: string
          wallet_id: string
          category_id: string | null
          credit_card_id: string | null
          description: string
          amount: number
          type: "income" | "expense" | "transfer"
          date: string
          is_paid: boolean
          is_recurring: boolean
          recurrence_frequency: string | null
          recurrence_end_date: string | null
          notes: string | null
          created_at: string
          updated_at: string
          workspace_id: string | null
        }
        Insert: {
          id?: string
          user_id: string
          wallet_id: string
          category_id?: string | null
          credit_card_id?: string | null
          description: string
          amount: number
          type: "income" | "expense" | "transfer"
          date?: string
          is_paid?: boolean
          is_recurring?: boolean
          recurrence_frequency?: string | null
          recurrence_end_date?: string | null
          notes?: string | null
          created_at?: string
          updated_at?: string
          workspace_id?: string | null
        }
        Update: {
          id?: string
          user_id?: string
          wallet_id?: string
          category_id?: string | null
          credit_card_id?: string | null
          description?: string
          amount?: number
          type?: "income" | "expense" | "transfer"
          date?: string
          is_paid?: boolean
          is_recurring?: boolean
          recurrence_frequency?: string | null
          recurrence_end_date?: string | null
          notes?: string | null
          created_at?: string
          updated_at?: string
          workspace_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "transactions_category_id_fkey"
            columns: ["category_id"]
            referencedRelation: "categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "transactions_credit_card_id_fkey"
            columns: ["credit_card_id"]
            referencedRelation: "credit_cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "transactions_user_id_fkey"
            columns: ["user_id"]
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "transactions_wallet_id_fkey"
            columns: ["wallet_id"]
            referencedRelation: "wallets"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "transactions_workspace_id_fkey"
            columns: ["workspace_id"]
            referencedRelation: "workspaces"
            referencedColumns: ["id"]
          }
        ]
      }
      wallets: {
        Row: {
          id: string
          created_at: string
          name: string
          balance: number
          user_id: string
          color: string | null
          icon: string | null
          is_default: boolean
          workspace_id: string | null
        }
        Insert: {
          id?: string
          created_at?: string
          name: string
          balance?: number
          user_id: string
          color?: string | null
          icon?: string | null
          is_default?: boolean
          workspace_id?: string | null
        }
        Update: {
          id?: string
          created_at?: string
          name?: string
          balance?: number
          user_id?: string
          color?: string | null
          icon?: string | null
          is_default?: boolean
          workspace_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "wallets_user_id_fkey"
            columns: ["user_id"]
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "wallets_workspace_id_fkey"
            columns: ["workspace_id"]
            referencedRelation: "workspaces"
            referencedColumns: ["id"]
          }
        ]
      }
      workspace_members: {
        Row: {
          workspace_id: string
          user_id: string
          role: string
          created_at: string
          updated_at: string
        }
        Insert: {
          workspace_id: string
          user_id: string
          role: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          workspace_id?: string
          user_id?: string
          role?: string
          created_at?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "workspace_members_user_id_fkey"
            columns: ["user_id"]
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "workspace_members_workspace_id_fkey"
            columns: ["workspace_id"]
            referencedRelation: "workspaces"
            referencedColumns: ["id"]
          }
        ]
      }
      workspaces: {
        Row: {
          id: string
          name: string
          description: string | null
          owner_id: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          description?: string | null
          owner_id: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          description?: string | null
          owner_id?: string
          created_at?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "workspaces_owner_id_fkey"
            columns: ["owner_id"]
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          }
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      create_notification: {
        Args: {
          user_id_param: string
          title_param: string
          message_param: string
          type_param?: string
          link_param?: string
        }
        Returns: string
      }
      get_cash_flow: {
        Args: {
          start_date_param?: string
          end_date_param?: string
        }
        Returns: {
          date: string
          income: number
          expense: number
          balance: number
        }[]
      }
      get_category_summary: {
        Args: {
          start_date_param?: string
          end_date_param?: string
          transaction_type?: string
        }
        Returns: {
          category_id: string
          category_name: string
          category_color: string
          category_icon: string
          total_amount: number
          percentage: number
        }[]
      }
      get_current_plan: {
        Args: {
          user_id_param?: string
        }
        Returns: {
          subscription_id: string
          plan_id: string
          plan_name: string
          plan_price: number
          plan_interval: string
          plan_features: Json
          status: string
          current_period_end: string
          cancel_at_period_end: boolean
        }[]
      }
      get_monthly_summary: {
        Args: {
          year_param?: number
          month_param?: number
        }
        Returns: {
          month: number
          year: number
          total_income: number
          total_expense: number
          balance: number
        }[]
      }
      get_unread_notifications: {
        Args: Record<PropertyKey, never>
        Returns: {
          id: string
          title: string
          message: string
          type: string
          link: string
          created_at: string
        }[]
      }
      get_workspace_resources: {
        Args: {
          workspace_id_param: string
        }
        Returns: {
          resource_type: string
          resource_id: string
          resource_name: string
          created_at: string
        }[]
      }
      has_active_subscription: {
        Args: {
          user_id_param?: string
        }
        Returns: boolean
      }
      has_workspace_role: {
        Args: {
          workspace_id: string
          role: string
          user_id?: string
        }
        Returns: boolean
      }
      is_workspace_member: {
        Args: {
          workspace_id: string
          user_id?: string
        }
        Returns: boolean
      }
      mark_all_notifications_as_read: {
        Args: Record<PropertyKey, never>
        Returns: number
      }
      mark_notification_as_read: {
        Args: {
          notification_id_param: string
        }
        Returns: boolean
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}
