-- ============================================================
-- Online Voting System — Database Schema
-- Run this in: Supabase → SQL Editor → New Query
-- ============================================================

-- ENUMS
CREATE TYPE user_role AS ENUM ('super_admin', 'election_admin', 'candidate', 'voter');
CREATE TYPE user_status AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE election_status AS ENUM ('draft', 'live', 'closed');

-- ============================================================
-- TABLE: users
-- Covers: Voter_Login.jsp, Candidate_Login.jsp, Login.jsp, register.jsp
-- ============================================================
CREATE TABLE users (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id    VARCHAR(50) UNIQUE,                    -- unique college/school ID
  name          VARCHAR(150) NOT NULL,
  email         VARCHAR(255) UNIQUE,
  phone         VARCHAR(20),
  password_hash TEXT,                                  -- null if Google SSO only
  role          user_role NOT NULL DEFAULT 'voter',
  status        user_status NOT NULL DEFAULT 'pending', -- admin approves voters
  institution   VARCHAR(200),                          -- school or college name
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLE: elections
-- Covers: CastElection.jsp, view_elections.jsp
-- ============================================================
CREATE TABLE elections (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title         VARCHAR(200) NOT NULL,
  description   TEXT,
  institution   VARCHAR(200),
  status        election_status NOT NULL DEFAULT 'draft',
  start_date    TIMESTAMPTZ,
  end_date      TIMESTAMPTZ,
  created_by    UUID REFERENCES users(id),             -- election admin
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLE: candidates
-- Covers: candidate.jsp, candidate_list.jsp, Candidate_Login.jsp
-- ============================================================
CREATE TABLE candidates (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID REFERENCES users(id) ON DELETE CASCADE,
  election_id   UUID REFERENCES elections(id) ON DELETE CASCADE,
  position      VARCHAR(150) NOT NULL,                 -- e.g. "President", "Secretary"
  manifesto     TEXT,
  photo_url     TEXT,
  status        user_status NOT NULL DEFAULT 'pending', -- admin approves candidate
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, election_id)                         -- one candidate entry per election
);

-- ============================================================
-- TABLE: votes
-- Covers: CastVote.jsp
-- KEY: UNIQUE constraint prevents double voting at DB level
-- ============================================================
CREATE TABLE votes (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  voter_id      UUID REFERENCES users(id) ON DELETE CASCADE,
  candidate_id  UUID REFERENCES candidates(id) ON DELETE CASCADE,
  election_id   UUID REFERENCES elections(id) ON DELETE CASCADE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(voter_id, election_id)                        -- CRITICAL: one vote per voter per election
);

-- ============================================================
-- TABLE: audit_logs
-- NEW: Not in reference repo — tamper-proof log
-- Stores hash only — NOT who voted for whom
-- ============================================================
CREATE TABLE audit_logs (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  election_id   UUID REFERENCES elections(id) ON DELETE CASCADE,
  vote_hash     TEXT NOT NULL,                         -- SHA-256(voter_id + election_id + timestamp)
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- VIEW: live_results
-- NEW: Powers real-time results dashboard
-- Covers: result.jsp, candidatewise_report.jsp (upgraded with live count)
-- ============================================================
CREATE OR REPLACE VIEW live_results AS
  SELECT
    c.id          AS candidate_id,
    u.name        AS candidate_name,
    c.position,
    c.election_id,
    e.title       AS election_title,
    COUNT(v.id)   AS vote_count
  FROM candidates c
  JOIN users u       ON u.id = c.user_id
  JOIN elections e   ON e.id = c.election_id
  LEFT JOIN votes v  ON v.candidate_id = c.id
  WHERE c.status = 'approved'
  GROUP BY c.id, u.name, c.position, c.election_id, e.title
  ORDER BY vote_count DESC;

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_votes_election ON votes(election_id);
CREATE INDEX idx_votes_voter    ON votes(voter_id);
CREATE INDEX idx_candidates_election ON candidates(election_id);
CREATE INDEX idx_audit_election ON audit_logs(election_id);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- Enable after connecting NextAuth / Supabase Auth
-- ============================================================
ALTER TABLE users        ENABLE ROW LEVEL SECURITY;
ALTER TABLE elections    ENABLE ROW LEVEL SECURITY;
ALTER TABLE candidates   ENABLE ROW LEVEL SECURITY;
ALTER TABLE votes        ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs   ENABLE ROW LEVEL SECURITY;

-- Voters can only read their own row
CREATE POLICY "Voters read own profile"
  ON users FOR SELECT USING (auth.uid() = id);

-- Admins can read all users
CREATE POLICY "Admins read all users"
  ON users FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('election_admin', 'super_admin'))
  );

-- Only election admins can insert/update elections
CREATE POLICY "Admins manage elections"
  ON elections FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('election_admin', 'super_admin'))
  );

-- Voters can only insert their own vote
CREATE POLICY "Voters cast own vote"
  ON votes FOR INSERT WITH CHECK (voter_id = auth.uid());

-- Votes are not readable by voters (anonymity)
CREATE POLICY "Admins read votes"
  ON votes FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('election_admin', 'super_admin'))
  );
