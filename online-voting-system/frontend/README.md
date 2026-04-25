# Frontend — Next.js 14

## Setup

```bash
cd frontend
cp .env.example .env.local   # fill in your Supabase + NextAuth keys
npm install
npm run dev                  # http://localhost:3000
```

## Environment Variables

```env
# .env.example
NEXT_PUBLIC_SUPABASE_URL=https://xxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

NEXTAUTH_SECRET=your-nextauth-secret
NEXTAUTH_URL=http://localhost:3000

GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
```

## Folder Structure

```
frontend/
├── src/
│   ├── app/                        # Next.js App Router
│   │   ├── layout.tsx              # Root layout (fonts, providers)
│   │   ├── page.tsx                # Landing / home page
│   │   ├── auth/                   # Auth pages (public)
│   │   │   ├── login/              # Voter login → Voter_Login.jsp equiv
│   │   │   ├── register/           # Voter registration → register.jsp equiv
│   │   │   └── candidate-login/    # Candidate login → Candidate_Login.jsp equiv
│   │   ├── dashboard/              # Protected dashboards (role-gated)
│   │   │   ├── admin/              # Admin_dashboard.jsp equiv
│   │   │   ├── voter/              # voter_dashboard.jsp equiv
│   │   │   ├── candidate/          # Candidate profile & vote tracker
│   │   │   └── super-admin/        # Super Admin — manage all admins
│   │   └── api/                    # Next.js API routes (backend logic)
│   │       ├── auth/               # NextAuth config
│   │       ├── elections/          # CRUD for elections
│   │       ├── candidates/         # Candidate registration, approval
│   │       ├── votes/              # Cast vote + double-vote guard
│   │       ├── results/            # Live count queries
│   │       └── audit/              # Audit log read endpoint
│   │
│   ├── components/
│   │   ├── ui/                     # Base: Button, Input, Card, Badge, Modal
│   │   ├── auth/                   # LoginForm, RegisterForm, OTPInput
│   │   ├── elections/              # ElectionCard, ElectionForm, StatusBadge
│   │   ├── candidates/             # CandidateCard, CandidateForm, ManifestoBox
│   │   ├── voting/                 # BallotCard, VoteConfirmModal, ReceiptCard
│   │   ├── results/                # LiveBarChart, ResultsTable, WinnerBanner
│   │   ├── admin/                  # VoterApprovalTable, ElectionControls
│   │   └── shared/                 # Navbar, Sidebar, Footer, LoadingSpinner
│   │
│   ├── hooks/
│   │   ├── useElections.ts         # Fetch + subscribe to elections
│   │   ├── useLiveResults.ts       # Supabase realtime vote count
│   │   ├── useAuth.ts              # Session, role helpers
│   │   └── useVoteStatus.ts        # Has current voter already voted?
│   │
│   ├── lib/
│   │   ├── supabase/
│   │   │   ├── client.ts           # Browser Supabase client
│   │   │   └── server.ts           # Server-side Supabase client
│   │   ├── utils/
│   │   │   ├── hash.ts             # SHA-256 audit hash generator
│   │   │   ├── date.ts             # Election timing helpers
│   │   │   └── roles.ts            # Role constants + guard helpers
│   │   └── validators/
│   │       ├── election.ts         # Zod schema for election form
│   │       ├── vote.ts             # Zod schema for vote submission
│   │       └── register.ts         # Zod schema for voter registration
│   │
│   ├── types/
│   │   └── index.ts                # Shared TS types (Election, Candidate, Vote, User)
│   │
│   └── styles/
│       └── globals.css             # Tailwind base styles
│
├── public/
│   └── assets/
│       ├── images/                 # Logos, hero images
│       └── icons/                  # SVG icons
│
├── middleware.ts                   # Route protection by role
├── next.config.js
├── tailwind.config.js
├── tsconfig.json
└── package.json
```

## Page → JSP Reference Map

| Next.js Page | JSP Equivalent | Notes |
|---|---|---|
| `/auth/login` | `Voter_Login.jsp` | Add Google SSO |
| `/auth/candidate-login` | `Candidate_Login.jsp` | Same pattern |
| `/auth/register` | `register.jsp` | Add validation |
| `/dashboard/admin` | `Admin_dashboard.jsp` | Add status toggles |
| `/dashboard/voter` | `voter_dashboard.jsp` | Add live count |
| `/dashboard/admin/elections` | `view_elections.jsp` | Add live badges |
| `/dashboard/admin/elections/new` | `CastElection.jsp` | React form |
| `/dashboard/admin/candidates` | `candidate_list.jsp` | With photos |
| `/dashboard/admin/voters` | `voter_list.jsp` | Approve/reject |
| `/dashboard/voter/vote` | `CastVote.jsp` | + audit hash |
| `/dashboard/voter/candidates` | `view_candidate_for_voter.jsp` | Cards UI |
| `/dashboard/admin/results` | `result.jsp` | + live chart |
| `/dashboard/admin/reports` | `candidatewise_report.jsp` | + Recharts |
