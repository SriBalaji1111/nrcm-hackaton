# 🗳️ Online Voting System — PS19

> Secure, real-time online voting platform for educational institutions (schools & colleges).
> Built for hackathon demo · expandable to production.

---

## 📌 Problem Statement

Traditional campus elections are slow, manual, and hard to scale. This system replaces paper-based voting with a secure, transparent, real-time digital platform supporting multiple roles, live results, and a tamper-proof audit trail.

---

## 🏗️ Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Next.js 14 (App Router) + Tailwind CSS |
| Backend | Next.js API Routes (Node.js) |
| Database | Supabase (PostgreSQL) |
| Auth | NextAuth.js + Supabase Auth |
| Real-time | Supabase Realtime Subscriptions |
| Charts | Recharts |
| Deployment | Vercel |

---

## 👥 User Roles

| Role | Access |
|---|---|
| **Super Admin** | Manage all institutions, election admins, system config |
| **Election Admin** | Create elections, manage candidates, control timing |
| **Candidate** | View profile, track own vote count |
| **Voter** | Register, authenticate, cast vote, view results |

---

## 📁 Project Structure

```
online-voting-system/
├── frontend/               # Next.js 14 App
├── backend/                # API logic (controllers, services, middleware)
├── docs/                   # API docs, DB schema, workflow diagrams
├── scripts/                # DB seed, migration scripts
└── .github/                # CI/CD workflows, issue templates
```

See each folder's own `README.md` for detailed setup instructions.

---

## 🚀 Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/YOUR_ORG/online-voting-system.git
cd online-voting-system

# 2. Setup frontend
cd frontend
cp .env.example .env.local
npm install
npm run dev

# 3. Setup database
# Go to supabase.com → New project → SQL Editor
# Run: scripts/01_schema.sql then scripts/02_seed.sql

# 4. Open http://localhost:3000
```

---

## 🗺️ Feature Checklist

### Core (Hackathon MVP)
- [x] 3 separate login flows (Voter / Candidate / Admin)
- [x] Student ID + Password auth
- [x] Google SSO (via NextAuth)
- [x] Election creation and management
- [x] Candidate profile setup
- [x] Voter approval workflow
- [x] Vote casting with double-vote prevention
- [x] Real-time live vote count
- [x] Results dashboard with bar chart
- [x] Tamper-proof audit trail (SHA-256 hash per vote)

### Extended (Post-Hackathon)
- [ ] Phone OTP verification (Twilio)
- [ ] Email OTP verification
- [ ] Face recognition at login
- [ ] Multi-institution support
- [ ] Fine-grained RBAC
- [ ] PDF result export
- [ ] Email notifications

---

## 🔐 Security Highlights

- **Double-vote prevention**: `UNIQUE(voter_id, election_id)` DB constraint + API-level check
- **Audit trail**: Every vote generates a `SHA-256(voter_id + election_id + timestamp)` hash stored in `audit_logs`
- **Role guards**: Next.js middleware checks JWT role on every protected route
- **Vote anonymity**: Audit log stores hash only — not who voted for whom

---

## 👨‍💻 Team Workflow

| Branch | Purpose |
|---|---|
| `main` | Production-ready code only |
| `dev` | Integration branch |
| `feature/auth` | Auth module work |
| `feature/elections` | Election management |
| `feature/voting` | Vote casting engine |
| `feature/results` | Results and reporting |

**Commit convention**: `feat:`, `fix:`, `chore:`, `docs:`

---

## 📄 Reference

- Original JSP reference: [shubhamdsk/Online-Voting-System](https://github.com/shubhamdsk/Online-Voting-System)
- Problem Statement: PS19 — Marketing/Social Media Category
