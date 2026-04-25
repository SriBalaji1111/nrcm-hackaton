/**
 * Supabase Types — Generated from DB Schema
 * Re-generate with: npx supabase gen types typescript --project-id YOUR_PROJECT_ID
 */

export type UserRole = 'super_admin' | 'election_admin' | 'candidate' | 'voter'
export type UserStatus = 'pending' | 'approved' | 'rejected'
export type ElectionStatus = 'draft' | 'live' | 'closed'

export interface User {
  id: string
  student_id: string | null
  name: string
  email: string | null
  phone: string | null
  role: UserRole
  status: UserStatus
  institution: string | null
  created_at: string
  updated_at: string
}

export interface Election {
  id: string
  title: string
  description: string | null
  institution: string | null
  status: ElectionStatus
  start_date: string | null
  end_date: string | null
  created_by: string
  created_at: string
  updated_at: string
}

export interface Candidate {
  id: string
  user_id: string
  election_id: string
  position: string
  manifesto: string | null
  photo_url: string | null
  status: UserStatus
  created_at: string
  // Joined fields (from queries)
  name?: string
  email?: string
}

export interface Vote {
  id: string
  voter_id: string
  candidate_id: string
  election_id: string
  created_at: string
}

export interface AuditLog {
  id: string
  election_id: string
  vote_hash: string
  created_at: string
}

export interface LiveResult {
  candidate_id: string
  candidate_name: string
  position: string
  election_id: string
  election_title: string
  vote_count: number
}

// API response wrapper
export interface ApiResponse<T = void> {
  success: boolean
  data?: T
  error?: string
  code?: string
}
