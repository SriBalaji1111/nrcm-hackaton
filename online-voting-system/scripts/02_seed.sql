-- ============================================================
-- Online Voting System — Seed / Demo Data
-- Run AFTER 01_schema.sql
-- ============================================================

-- Super Admin
INSERT INTO users (id, student_id, name, email, role, status, institution)
VALUES
  ('00000000-0000-0000-0000-000000000001', 'SUPER001', 'Super Admin', 'super@campus.edu', 'super_admin', 'approved', 'System'),
  ('00000000-0000-0000-0000-000000000002', 'ADMIN001', 'Election Admin 1', 'admin1@campus.edu', 'election_admin', 'approved', 'State Engineering College'),
  ('00000000-0000-0000-0000-000000000003', 'ADMIN002', 'Election Admin 2', 'admin2@campus.edu', 'election_admin', 'approved', 'City High School');

-- Demo Voters (password: demo1234 — bcrypt hashed in real app)
INSERT INTO users (id, student_id, name, email, role, status, institution)
VALUES
  ('00000000-0000-0000-0000-000000000010', 'STU001', 'Aditya Sharma', 'aditya@campus.edu', 'voter', 'approved', 'State Engineering College'),
  ('00000000-0000-0000-0000-000000000011', 'STU002', 'Priya Nair', 'priya@campus.edu', 'voter', 'approved', 'State Engineering College'),
  ('00000000-0000-0000-0000-000000000012', 'STU003', 'Rahul Desai', 'rahul@campus.edu', 'voter', 'approved', 'State Engineering College'),
  ('00000000-0000-0000-0000-000000000013', 'STU004', 'Sneha Reddy', 'sneha@campus.edu', 'voter', 'pending', 'State Engineering College');

-- Demo Candidates (also registered as users)
INSERT INTO users (id, student_id, name, email, role, status, institution)
VALUES
  ('00000000-0000-0000-0000-000000000020', 'CAN001', 'Vikram Mehta', 'vikram@campus.edu', 'candidate', 'approved', 'State Engineering College'),
  ('00000000-0000-0000-0000-000000000021', 'CAN002', 'Anjali Patel', 'anjali@campus.edu', 'candidate', 'approved', 'State Engineering College'),
  ('00000000-0000-0000-0000-000000000022', 'CAN003', 'Rohan Joshi', 'rohan@campus.edu', 'candidate', 'approved', 'State Engineering College');

-- Demo Elections
INSERT INTO elections (id, title, description, institution, status, start_date, end_date, created_by)
VALUES
  (
    '10000000-0000-0000-0000-000000000001',
    'Student Council Elections 2025',
    'Annual student council elections for the academic year 2025-26. Vote for your President, Secretary, and Treasurer.',
    'State Engineering College',
    'live',
    NOW() - INTERVAL '1 hour',
    NOW() + INTERVAL '23 hours',
    '00000000-0000-0000-0000-000000000002'
  ),
  (
    '10000000-0000-0000-0000-000000000002',
    'Cultural Committee Elections 2025',
    'Elect the cultural committee head for organizing college fests.',
    'State Engineering College',
    'draft',
    NOW() + INTERVAL '3 days',
    NOW() + INTERVAL '4 days',
    '00000000-0000-0000-0000-000000000002'
  );

-- Demo Candidates (linked to election)
INSERT INTO candidates (id, user_id, election_id, position, manifesto, status)
VALUES
  (
    '20000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000020',
    '10000000-0000-0000-0000-000000000001',
    'President',
    'I will work to improve campus infrastructure, introduce more industry-academia programs, and ensure transparent governance.',
    'approved'
  ),
  (
    '20000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000021',
    '10000000-0000-0000-0000-000000000001',
    'President',
    'My focus is student welfare, mental health support, and modernizing the library and labs.',
    'approved'
  ),
  (
    '20000000-0000-0000-0000-000000000003',
    '00000000-0000-0000-0000-000000000022',
    '10000000-0000-0000-0000-000000000001',
    'Secretary',
    'I will ensure clear communication between students and faculty, and digitize all student records.',
    'approved'
  );

-- Demo Votes (Aditya and Priya have already voted)
INSERT INTO votes (voter_id, candidate_id, election_id)
VALUES
  ('00000000-0000-0000-0000-000000000010', '20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001'),
  ('00000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001');

-- Demo Audit Logs (matching the votes above)
INSERT INTO audit_logs (election_id, vote_hash)
VALUES
  ('10000000-0000-0000-0000-000000000001', 'a3f5c2e8b1d94f6072e3ac819d4e571f2cc8b64a07d1395e68fc3b2a1d5e9087'),
  ('10000000-0000-0000-0000-000000000001', 'b8d2a1f4c6e3957081f4bc920e5d682g3dd9c75b18e2406f79gd4c3b2e6f1098');

-- ============================================================
-- Demo Credentials Summary
-- ============================================================
-- Super Admin : super@campus.edu   / password: demo1234
-- Election Admin: admin1@campus.edu / password: demo1234
-- Voter (voted): aditya@campus.edu  / Student ID: STU001
-- Voter (voted): priya@campus.edu   / Student ID: STU002
-- Voter (not voted): rahul@campus.edu / Student ID: STU003
-- Voter (pending approval): sneha@campus.edu / Student ID: STU004
-- Candidate: vikram@campus.edu / Student ID: CAN001
