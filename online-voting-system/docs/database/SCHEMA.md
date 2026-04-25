# Database Schema Reference

## Overview

| Table | JSP Equivalent | Purpose |
|---|---|---|
| `users` | register.jsp, all login JSPs | All users (voters, candidates, admins) |
| `elections` | CastElection.jsp | Election records |
| `candidates` | candidate.jsp | Candidates per election |
| `votes` | CastVote.jsp | Vote records (anonymized) |
| `audit_logs` | *(not in ref repo)* | Tamper-proof vote trail |
| `live_results` view | result.jsp | Aggregated live vote count |

---

## Entity Relationship

```
users ─────────────── candidates ─────── elections
  │                        │                  │
  │ (voter)                │                  │
  └────────── votes ───────┘                  │
                │                             │
                └────────── audit_logs ───────┘
```

---

## Table Details

### users
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | Auto-generated |
| student_id | VARCHAR(50) UNIQUE | College/school roll number |
| name | VARCHAR(150) | Full name |
| email | VARCHAR(255) UNIQUE | For Google SSO |
| phone | VARCHAR(20) | For phone OTP (future) |
| password_hash | TEXT | bcrypt hash; null for SSO users |
| role | ENUM | `super_admin / election_admin / candidate / voter` |
| status | ENUM | `pending / approved / rejected` |
| institution | VARCHAR(200) | School or college name |

### elections
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | Auto-generated |
| title | VARCHAR(200) | Election name |
| description | TEXT | Full description |
| institution | VARCHAR(200) | Which institution this is for |
| status | ENUM | `draft / live / closed` — controlled by admin |
| start_date | TIMESTAMPTZ | When voting opens |
| end_date | TIMESTAMPTZ | When voting closes |
| created_by | UUID FK → users | Election admin who created it |

### candidates
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | Auto-generated |
| user_id | UUID FK → users | The person running |
| election_id | UUID FK → elections | Which election |
| position | VARCHAR(150) | e.g. "President", "Secretary" |
| manifesto | TEXT | Campaign manifesto |
| photo_url | TEXT | Uploaded profile photo |
| status | ENUM | `pending / approved / rejected` |
| UNIQUE | (user_id, election_id) | One entry per candidate per election |

### votes
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | Auto-generated |
| voter_id | UUID FK → users | Who voted |
| candidate_id | UUID FK → candidates | Who they voted for |
| election_id | UUID FK → elections | Which election |
| created_at | TIMESTAMPTZ | Timestamp |
| UNIQUE | **(voter_id, election_id)** | **CRITICAL: prevents double voting** |

### audit_logs
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | Auto-generated |
| election_id | UUID FK → elections | Which election |
| vote_hash | TEXT | `SHA-256(voter_id + election_id + timestamp)` |
| created_at | TIMESTAMPTZ | When the vote was cast |

> Note: The audit log does NOT store `voter_id` or `candidate_id` — it only stores the hash.
> This preserves vote anonymity while providing tamper-proof evidence that a vote occurred.

---

## How the Double-Vote Guard Works

1. **API layer** — on `POST /api/votes`, check if a vote with `(voter_id, election_id)` already exists. Return 409 if so.
2. **Database layer** — `UNIQUE(voter_id, election_id)` constraint on `votes` table. Even if two concurrent requests slip past the API check, only one INSERT will succeed. The other will get a Postgres unique constraint violation.

This two-layer protection handles both normal cases and race conditions.

---

## Supabase Realtime Configuration

To enable live results, go to:
**Supabase Dashboard → Table Editor → votes table → Enable Realtime**

The `useLiveResults` hook subscribes to INSERT events on the `votes` table and re-queries the `live_results` view on each new vote.
