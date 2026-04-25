# API Documentation

## Base URL
- Development: `http://localhost:3000/api`
- Production: `https://your-vercel-app.vercel.app/api`

## Authentication
All protected routes require a valid session cookie (set by NextAuth).
Include credentials in fetch calls: `credentials: 'include'`

---

## Auth Endpoints

### POST `/api/auth/register`
Register a new voter.

**Body:**
```json
{
  "student_id": "STU005",
  "name": "New Student",
  "email": "new@campus.edu",
  "password": "securepassword",
  "institution": "State Engineering College"
}
```

**Response 201:**
```json
{
  "success": true,
  "message": "Registration successful. Awaiting admin approval.",
  "user_id": "uuid"
}
```

**Error 409** — Student ID already exists.

---

### POST `/api/auth/[...nextauth]`
Handled by NextAuth. Supports:
- `credentials` provider (Student ID + Password)
- `google` provider (Google OAuth)

---

## Elections Endpoints

### GET `/api/elections`
List elections. Filtered by role automatically.

**Query params:**
- `status` — `draft | live | closed` (optional)
- `institution` — filter by institution (optional)

**Response 200:**
```json
{
  "elections": [
    {
      "id": "uuid",
      "title": "Student Council Elections 2025",
      "status": "live",
      "start_date": "2025-01-15T09:00:00Z",
      "end_date": "2025-01-16T17:00:00Z",
      "candidate_count": 3
    }
  ]
}
```

---

### POST `/api/elections`
Create a new election. **Role: election_admin, super_admin**

**Body:**
```json
{
  "title": "Cultural Committee Elections",
  "description": "Elect the cultural head",
  "start_date": "2025-02-01T09:00:00Z",
  "end_date": "2025-02-02T17:00:00Z"
}
```

**Response 201:**
```json
{ "success": true, "election_id": "uuid" }
```

---

### PATCH `/api/elections/:id/status`
Change election status. **Role: election_admin, super_admin**

**Body:**
```json
{ "status": "live" }
```

Valid transitions: `draft → live`, `live → closed`

---

## Candidates Endpoints

### GET `/api/candidates`
List approved candidates for an election.

**Query:** `?election_id=uuid`

**Response 200:**
```json
{
  "candidates": [
    {
      "id": "uuid",
      "name": "Vikram Mehta",
      "position": "President",
      "manifesto": "I will improve...",
      "photo_url": "https://..."
    }
  ]
}
```

---

### POST `/api/candidates`
Register as a candidate for an election. **Role: candidate**

**Body:**
```json
{
  "election_id": "uuid",
  "position": "President",
  "manifesto": "My manifesto here"
}
```

---

## Votes Endpoints

### POST `/api/votes`
Cast a vote. **Role: voter (approved only)**

**Body:**
```json
{
  "candidate_id": "uuid",
  "election_id": "uuid"
}
```

**Response 200:**
```json
{
  "success": true,
  "receipt_hash": "a3f5c2e8b1d94f6072e3ac819d4e571f..."
}
```

**Error 409** — Already voted in this election.
**Error 403** — Election not live, or voter not approved.

---

### GET `/api/votes/status`
Check if current voter has voted in an election.

**Query:** `?election_id=uuid`

**Response:**
```json
{ "has_voted": true }
```

---

## Results Endpoints

### GET `/api/results/:election_id`
Live vote counts for all candidates.

**Response 200:**
```json
{
  "election_id": "uuid",
  "election_title": "Student Council Elections 2025",
  "status": "live",
  "results": [
    { "candidate_id": "uuid", "name": "Vikram Mehta", "position": "President", "vote_count": 42 },
    { "candidate_id": "uuid", "name": "Anjali Patel", "position": "President", "vote_count": 37 }
  ],
  "total_votes": 79,
  "last_updated": "2025-01-15T14:32:00Z"
}
```

---

## Audit Endpoints

### GET `/api/audit`
Paginated audit log. **Role: election_admin, super_admin**

**Query:** `?election_id=uuid&page=1&limit=50`

**Response 200:**
```json
{
  "audit_logs": [
    {
      "id": "uuid",
      "election_id": "uuid",
      "vote_hash": "a3f5c2e8...",
      "created_at": "2025-01-15T10:05:00Z"
    }
  ],
  "total": 79,
  "page": 1
}
```

---

## Error Response Format

All errors follow this structure:
```json
{
  "success": false,
  "error": "Human-readable error message",
  "code": "ERROR_CODE"
}
```

Common codes: `ALREADY_VOTED`, `ELECTION_NOT_LIVE`, `VOTER_NOT_APPROVED`, `UNAUTHORIZED`, `NOT_FOUND`
