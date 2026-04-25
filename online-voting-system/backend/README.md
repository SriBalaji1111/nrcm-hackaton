# Backend — API Layer

> All API logic lives inside `frontend/src/app/api/` as Next.js Route Handlers.
> This folder (`backend/`) contains the extracted controller, service, and middleware
> logic as pure TypeScript modules — imported by the API routes.

## Why this structure?

Separating business logic from route handlers makes it:
- Testable (unit test services without HTTP)
- Reusable (share logic across multiple routes)
- Clear for team members to find where logic lives

## Folder Structure

```
backend/
├── src/
│   ├── controllers/            # Request handling (thin layer — calls services)
│   │   ├── auth.controller.ts
│   │   ├── elections.controller.ts
│   │   ├── candidates.controller.ts
│   │   ├── votes.controller.ts
│   │   ├── results.controller.ts
│   │   └── audit.controller.ts
│   │
│   ├── services/               # Core business logic
│   │   ├── auth.service.ts         # Login, register, role assignment
│   │   ├── elections.service.ts    # Create, update, status transition
│   │   ├── candidates.service.ts   # Add candidate, approve, reject
│   │   ├── votes.service.ts        # Cast vote, double-vote check, audit log
│   │   ├── results.service.ts      # Count votes, aggregate, rank
│   │   └── audit.service.ts        # Generate + store audit hash
│   │
│   ├── middleware/             # Request guards
│   │   ├── auth.middleware.ts       # Verify JWT, extract user
│   │   ├── role.middleware.ts       # Check role (voter/admin/super-admin)
│   │   └── rateLimit.middleware.ts  # Prevent vote spam
│   │
│   ├── models/                 # TypeScript interfaces matching DB tables
│   │   ├── user.model.ts
│   │   ├── election.model.ts
│   │   ├── candidate.model.ts
│   │   ├── vote.model.ts
│   │   └── auditLog.model.ts
│   │
│   ├── routes/                 # Route constants + grouping reference
│   │   └── index.ts
│   │
│   ├── utils/
│   │   ├── hash.ts             # SHA-256 audit hash
│   │   ├── response.ts         # Standard API response helpers
│   │   └── errors.ts           # Custom error classes
│   │
│   └── config/
│       ├── supabase.ts         # Supabase admin client setup
│       └── constants.ts        # Role names, election statuses, etc.
│
└── tests/
    ├── unit/
    │   ├── votes.service.test.ts   # Double-vote prevention logic
    │   ├── audit.service.test.ts   # Hash generation
    │   └── results.service.test.ts # Vote count aggregation
    └── integration/
        ├── auth.test.ts
        └── elections.test.ts
```

## API Endpoints Reference

### Auth
| Method | Endpoint | Description | Role |
|---|---|---|---|
| POST | `/api/auth/register` | Voter self-registration | Public |
| POST | `/api/auth/login` | Student ID + password login | Public |
| GET | `/api/auth/session` | Get current session + role | Authenticated |

### Elections
| Method | Endpoint | Description | Role |
|---|---|---|---|
| GET | `/api/elections` | List all elections | Authenticated |
| POST | `/api/elections` | Create new election | Election Admin |
| PATCH | `/api/elections/:id/status` | Change status (draft→live→closed) | Election Admin |
| DELETE | `/api/elections/:id` | Delete draft election | Election Admin |

### Candidates
| Method | Endpoint | Description | Role |
|---|---|---|---|
| GET | `/api/candidates?election_id=` | List candidates for election | Authenticated |
| POST | `/api/candidates` | Add candidate to election | Election Admin |
| PATCH | `/api/candidates/:id/approve` | Approve candidate | Election Admin |

### Votes
| Method | Endpoint | Description | Role |
|---|---|---|---|
| POST | `/api/votes` | Cast a vote (idempotent, guarded) | Voter |
| GET | `/api/votes/status?election_id=` | Check if voter already voted | Voter |

### Results
| Method | Endpoint | Description | Role |
|---|---|---|---|
| GET | `/api/results/:election_id` | Live vote counts per candidate | Authenticated |
| GET | `/api/results/:election_id/winner` | Declared winner (if closed) | Authenticated |

### Audit
| Method | Endpoint | Description | Role |
|---|---|---|---|
| GET | `/api/audit?election_id=` | Paginated audit log | Election Admin |

## Core Vote Flow (votes.service.ts)

```typescript
// Pseudo-code — implement in backend/src/services/votes.service.ts
async function castVote(voterId, candidateId, electionId) {
  // 1. Check election is LIVE
  const election = await getElection(electionId)
  if (election.status !== 'live') throw new Error('Election not active')

  // 2. Check voter is approved
  const voter = await getUser(voterId)
  if (voter.status !== 'approved') throw new Error('Voter not approved')

  // 3. Check double-vote (DB UNIQUE constraint is the final guard)
  const existing = await checkExistingVote(voterId, electionId)
  if (existing) throw new Error('Already voted')

  // 4. Insert vote (UNIQUE constraint enforces atomicity)
  await insertVote({ voter_id: voterId, candidate_id: candidateId, election_id: electionId })

  // 5. Generate + store audit hash
  const hash = sha256(`${voterId}:${electionId}:${Date.now()}`)
  await insertAuditLog({ election_id: electionId, vote_hash: hash, created_at: new Date() })

  return { success: true, receipt_hash: hash }
}
```
