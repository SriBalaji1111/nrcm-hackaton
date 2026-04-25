# Team Workflow Guide

## 🧑‍💻 Team Structure & Module Ownership

| Module | Files to work on | Owner suggestion |
|---|---|---|
| **Auth** | `frontend/src/app/auth/`, `backend/src/services/auth.service.ts`, `frontend/src/components/auth/` | Team Member 1 |
| **Elections CRUD** | `frontend/src/app/dashboard/admin/`, `backend/src/services/elections.service.ts`, `frontend/src/components/elections/` | Team Member 2 |
| **Vote Engine** | `frontend/src/app/api/votes/`, `backend/src/services/votes.service.ts`, `frontend/src/components/voting/` | Team Member 3 |
| **Results + Charts** | `frontend/src/app/dashboard/`, `backend/src/services/results.service.ts`, `frontend/src/components/results/` | Team Member 4 |

---

## 🌿 Branching Strategy

```
main
 └── dev                    ← integration branch, PR here first
      ├── feature/auth       ← Team Member 1
      ├── feature/elections  ← Team Member 2
      ├── feature/voting     ← Team Member 3
      └── feature/results    ← Team Member 4
```

### Rules
- **Never push directly to `main`**
- All features → PR into `dev` → tested → merge to `main` before demo
- Each feature branch should be short-lived (hours, not days in a hackathon)

---

## 📝 Commit Convention

Format: `type(scope): short description`

| Type | When to use |
|---|---|
| `feat` | New feature or page |
| `fix` | Bug fix |
| `chore` | Config, deps, tooling |
| `docs` | README, comments |
| `style` | CSS/Tailwind only, no logic |
| `test` | Test files |

**Examples:**
```
feat(auth): add voter login form with student ID validation
fix(votes): prevent double-vote race condition on simultaneous submit
chore(db): add election status index to schema
docs(api): document POST /votes endpoint
```

---

## ✅ Task Checklist by Team Member

### Team Member 1 — Auth

- [ ] Set up NextAuth with credentials + Google provider
- [ ] `POST /api/auth/register` — voter self-registration
- [ ] Voter login page (`/auth/login`)
- [ ] Candidate login page (`/auth/candidate-login`)
- [ ] Admin login page (reuse login, role-check middleware)
- [ ] `middleware.ts` — protect dashboard routes by role
- [ ] Voter registration form with validation
- [ ] Voter approval API (admin approves/rejects)

### Team Member 2 — Elections

- [ ] Election list page for admin (`/dashboard/admin/elections`)
- [ ] Create election form (`/dashboard/admin/elections/new`)
- [ ] `POST /api/elections` — create election
- [ ] `PATCH /api/elections/:id/status` — draft → live → closed
- [ ] Candidate registration form for candidates
- [ ] Candidate approval table for admin
- [ ] Election status badge component (live/draft/closed)

### Team Member 3 — Vote Engine

- [ ] Candidate cards page for voters (`/dashboard/voter/candidates`)
- [ ] Vote confirmation modal
- [ ] `POST /api/votes` — cast vote with double-vote guard
- [ ] `GET /api/votes/status` — has voter already voted?
- [ ] Vote receipt page showing audit hash
- [ ] `audit_logs` table insert on each vote
- [ ] SHA-256 hash utility (`backend/src/utils/hash.ts`)

### Team Member 4 — Results

- [ ] Results dashboard (`/dashboard/admin/results`)
- [ ] Live bar chart using Recharts + Supabase realtime
- [ ] `GET /api/results/:election_id` — live count query
- [ ] `useLiveResults.ts` hook — subscribe to vote changes
- [ ] Voter results view (read-only live count)
- [ ] Audit log table in admin panel
- [ ] Winner banner when election is closed

---

## 🔄 Supabase Realtime Setup (Team Member 4)

```typescript
// frontend/src/hooks/useLiveResults.ts
import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase/client'

export function useLiveResults(electionId: string) {
  const [results, setResults] = useState([])

  useEffect(() => {
    // Initial fetch
    fetchResults()

    // Subscribe to new votes in real-time
    const channel = supabase
      .channel(`election-${electionId}`)
      .on('postgres_changes', {
        event: 'INSERT',
        schema: 'public',
        table: 'votes',
        filter: `election_id=eq.${electionId}`
      }, () => {
        fetchResults() // re-fetch on each new vote
      })
      .subscribe()

    return () => { supabase.removeChannel(channel) }
  }, [electionId])

  async function fetchResults() {
    const { data } = await supabase
      .from('live_results')
      .select('*')
      .eq('election_id', electionId)
    setResults(data ?? [])
  }

  return results
}
```

---

## 🧪 Demo Script (Hackathon Presentation)

**Total time: 3 minutes**

1. **[30s] Landing page** — Show the home page, explain the problem
2. **[30s] Admin flow** — Log in as Election Admin → show election list → activate the live election
3. **[30s] Voter registration** — Register a new voter → admin approves them in voter list
4. **[45s] Voting** — Log in as approved voter → see candidates → cast vote → show receipt hash
5. **[30s] Live results** — Open results dashboard → votes update in real-time on the bar chart
6. **[15s] Audit trail** — Show audit log table with hashed entries → "tamper-proof"

---

## ⚡ Common Issues & Fixes

| Issue | Fix |
|---|---|
| Supabase connection fails | Check `NEXT_PUBLIC_SUPABASE_URL` in `.env.local` |
| Google login doesn't redirect | Check `NEXTAUTH_URL` matches your dev URL exactly |
| Double vote not blocked | Ensure `UNIQUE(voter_id, election_id)` constraint exists in DB |
| Realtime not triggering | Enable Realtime for `votes` table in Supabase dashboard → Table Editor → Enable Realtime |
| 401 on API routes | Session cookie not passed — add `credentials: 'include'` to fetch |
