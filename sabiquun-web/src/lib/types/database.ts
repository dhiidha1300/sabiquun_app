// Database types for Supabase
// Generated based on existing Flutter models

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

// Enums
export type UserRole = 'user' | 'supervisor' | 'cashier' | 'admin'
export type AccountStatus = 'pending' | 'active' | 'suspended' | 'auto_deactivated' | 'deleted'
export type PaymentStatus = 'pending' | 'approved' | 'rejected'
export type PenaltyStatus = 'pending' | 'partial' | 'paid' | 'waived'
export type ReportStatus = 'draft' | 'submitted'
export type ExcuseStatus = 'pending' | 'approved' | 'rejected'
export type ExcuseType = 'sickness' | 'travel' | 'raining'
export type DeedCategory = 'faraid' | 'sunnah'
export type DeedValueType = 'binary' | 'fractional'

export interface Database {
  public: {
    Tables: {
      users: {
        Row: {
          id: string
          email: string
          name: string
          phone: string | null
          photo_url: string | null
          role: UserRole
          account_status: AccountStatus
          membership_status: string
          excuse_mode: boolean
          created_at: string
          approved_by: string | null
          approved_at: string | null
          updated_at: string
        }
        Insert: {
          id?: string
          email: string
          name: string
          phone?: string | null
          photo_url?: string | null
          role?: UserRole
          account_status?: AccountStatus
          membership_status?: string
          excuse_mode?: boolean
          created_at?: string
          approved_by?: string | null
          approved_at?: string | null
          updated_at?: string
        }
        Update: {
          id?: string
          email?: string
          name?: string
          phone?: string | null
          photo_url?: string | null
          role?: UserRole
          account_status?: AccountStatus
          membership_status?: string
          excuse_mode?: boolean
          created_at?: string
          approved_by?: string | null
          approved_at?: string | null
          updated_at?: string
        }
      }
      deed_templates: {
        Row: {
          id: string
          name: string
          name_ar: string | null
          description: string | null
          category: DeedCategory
          value_type: DeedValueType
          display_order: number
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          name_ar?: string | null
          description?: string | null
          category: DeedCategory
          value_type?: DeedValueType
          display_order?: number
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          name_ar?: string | null
          description?: string | null
          category?: DeedCategory
          value_type?: DeedValueType
          display_order?: number
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
      }
      deeds_reports: {
        Row: {
          id: string
          user_id: string
          report_date: string
          total_deeds: number
          sunnah_count: number
          faraid_count: number
          status: ReportStatus
          submitted_at: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          report_date: string
          total_deeds?: number
          sunnah_count?: number
          faraid_count?: number
          status?: ReportStatus
          submitted_at?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          report_date?: string
          total_deeds?: number
          sunnah_count?: number
          faraid_count?: number
          status?: ReportStatus
          submitted_at?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      deed_entries: {
        Row: {
          id: string
          report_id: string
          template_id: string
          value: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          report_id: string
          template_id: string
          value?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          report_id?: string
          template_id?: string
          value?: number
          created_at?: string
          updated_at?: string
        }
      }
      penalties: {
        Row: {
          id: string
          user_id: string
          report_id: string | null
          amount: number
          date_incurred: string
          status: PenaltyStatus
          paid_amount: number
          waived_by: string | null
          waived_reason: string | null
          missed_deeds: number | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          report_id?: string | null
          amount: number
          date_incurred: string
          status?: PenaltyStatus
          paid_amount?: number
          waived_by?: string | null
          waived_reason?: string | null
          missed_deeds?: number | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          report_id?: string | null
          amount?: number
          date_incurred?: string
          status?: PenaltyStatus
          paid_amount?: number
          waived_by?: string | null
          waived_reason?: string | null
          missed_deeds?: number | null
          created_at?: string
          updated_at?: string
        }
      }
      payments: {
        Row: {
          id: string
          user_id: string
          amount: number
          payment_method: string
          payment_type: string
          reference_number: string | null
          status: PaymentStatus
          submitted_at: string
          reviewed_by: string | null
          reviewed_at: string | null
          rejection_reason: string | null
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          amount: number
          payment_method: string
          payment_type: string
          reference_number?: string | null
          status?: PaymentStatus
          submitted_at?: string
          reviewed_by?: string | null
          reviewed_at?: string | null
          rejection_reason?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          amount?: number
          payment_method?: string
          payment_type?: string
          reference_number?: string | null
          status?: PaymentStatus
          submitted_at?: string
          reviewed_by?: string | null
          reviewed_at?: string | null
          rejection_reason?: string | null
          created_at?: string
        }
      }
      payment_methods: {
        Row: {
          id: string
          name: string
          description: string | null
          instructions: string | null
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          description?: string | null
          instructions?: string | null
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          description?: string | null
          instructions?: string | null
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
      }
      excuses: {
        Row: {
          id: string
          user_id: string
          excuse_type: ExcuseType
          start_date: string
          end_date: string
          reason: string | null
          status: ExcuseStatus
          reviewed_by: string | null
          reviewed_at: string | null
          rejection_reason: string | null
          affected_deeds: string[] | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          excuse_type: ExcuseType
          start_date: string
          end_date: string
          reason?: string | null
          status?: ExcuseStatus
          reviewed_by?: string | null
          reviewed_at?: string | null
          rejection_reason?: string | null
          affected_deeds?: string[] | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          excuse_type?: ExcuseType
          start_date?: string
          end_date?: string
          reason?: string | null
          status?: ExcuseStatus
          reviewed_by?: string | null
          reviewed_at?: string | null
          rejection_reason?: string | null
          affected_deeds?: string[] | null
          created_at?: string
          updated_at?: string
        }
      }
      settings: {
        Row: {
          id: string
          key: string
          value: Json
          description: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          key: string
          value: Json
          description?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          key?: string
          value?: Json
          description?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      audit_logs: {
        Row: {
          id: string
          user_id: string | null
          action: string
          entity_type: string
          entity_id: string | null
          old_values: Json | null
          new_values: Json | null
          ip_address: string | null
          user_agent: string | null
          created_at: string
        }
        Insert: {
          id?: string
          user_id?: string | null
          action: string
          entity_type: string
          entity_id?: string | null
          old_values?: Json | null
          new_values?: Json | null
          ip_address?: string | null
          user_agent?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string | null
          action?: string
          entity_type?: string
          entity_id?: string | null
          old_values?: Json | null
          new_values?: Json | null
          ip_address?: string | null
          user_agent?: string | null
          created_at?: string
        }
      }
      notification_templates: {
        Row: {
          id: string
          name: string
          type: string
          title_template: string
          body_template: string
          channels: string[]
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          type: string
          title_template: string
          body_template: string
          channels?: string[]
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          type?: string
          title_template?: string
          body_template?: string
          channels?: string[]
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
      }
      announcements: {
        Row: {
          id: string
          title: string
          content: string
          type: string
          is_active: boolean
          start_date: string | null
          end_date: string | null
          created_by: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          title: string
          content: string
          type?: string
          is_active?: boolean
          start_date?: string | null
          end_date?: string | null
          created_by: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          title?: string
          content?: string
          type?: string
          is_active?: boolean
          start_date?: string | null
          end_date?: string | null
          created_by?: string
          created_at?: string
          updated_at?: string
        }
      }
      rest_days: {
        Row: {
          id: string
          date: string
          reason: string
          is_recurring: boolean
          created_by: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          date: string
          reason: string
          is_recurring?: boolean
          created_by: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          date?: string
          reason?: string
          is_recurring?: boolean
          created_by?: string
          created_at?: string
          updated_at?: string
        }
      }
      app_content: {
        Row: {
          id: string
          key: string
          title: string
          content: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          key: string
          title: string
          content: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          key?: string
          title?: string
          content?: string
          created_at?: string
          updated_at?: string
        }
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      user_role: UserRole
      account_status: AccountStatus
      payment_status: PaymentStatus
      penalty_status: PenaltyStatus
      report_status: ReportStatus
      excuse_status: ExcuseStatus
      excuse_type: ExcuseType
      deed_category: DeedCategory
      deed_value_type: DeedValueType
    }
  }
}

// Convenience type aliases
export type User = Database['public']['Tables']['users']['Row']
export type UserInsert = Database['public']['Tables']['users']['Insert']
export type UserUpdate = Database['public']['Tables']['users']['Update']

export type DeedTemplate = Database['public']['Tables']['deed_templates']['Row']
export type DeedReport = Database['public']['Tables']['deeds_reports']['Row']
export type DeedEntry = Database['public']['Tables']['deed_entries']['Row']

export type Penalty = Database['public']['Tables']['penalties']['Row']
export type Payment = Database['public']['Tables']['payments']['Row']
export type PaymentMethod = Database['public']['Tables']['payment_methods']['Row']

export type Excuse = Database['public']['Tables']['excuses']['Row']
export type Setting = Database['public']['Tables']['settings']['Row']
export type AuditLog = Database['public']['Tables']['audit_logs']['Row']

export type NotificationTemplate = Database['public']['Tables']['notification_templates']['Row']
export type Announcement = Database['public']['Tables']['announcements']['Row']
export type RestDay = Database['public']['Tables']['rest_days']['Row']
export type AppContent = Database['public']['Tables']['app_content']['Row']

// Extended types with joined data
export interface PaymentWithDetails extends Payment {
  user?: Pick<User, 'id' | 'name' | 'email'> & {
    user_statistics?: { current_penalty_balance: number }
  }
  reviewer?: Pick<User, 'id' | 'name'>
}

export interface ExcuseWithDetails extends Excuse {
  user?: Pick<User, 'id' | 'name' | 'email'>
  reviewer?: Pick<User, 'id' | 'name'>
}

export interface DeedReportWithDetails extends DeedReport {
  user?: Pick<User, 'id' | 'name' | 'email'>
  entries?: (DeedEntry & { template?: DeedTemplate })[]
}

export interface PenaltyWithDetails extends Penalty {
  user?: Pick<User, 'id' | 'name' | 'email'>
  report?: DeedReport
}

export interface AuditLogWithDetails extends AuditLog {
  user?: Pick<User, 'id' | 'name' | 'email'>
}
