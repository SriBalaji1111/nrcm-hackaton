/**
 * Audit Trail Hash Generator
 * Generates a SHA-256 hash for each vote to create a tamper-proof audit trail.
 * The hash encodes THAT a vote occurred, not WHO voted for WHOM.
 *
 * Used in: backend/src/services/votes.service.ts
 * Referenced in: docs/database/SCHEMA.md
 */

import { sha256 } from 'js-sha256'

/**
 * Generate a deterministic audit hash for a vote event.
 * @param voterId - The voter's UUID
 * @param electionId - The election's UUID
 * @param timestamp - ISO timestamp of the vote
 * @returns SHA-256 hex string
 */
export function generateVoteHash(
  voterId: string,
  electionId: string,
  timestamp: string
): string {
  const payload = `${voterId}:${electionId}:${timestamp}`
  return sha256(payload)
}

/**
 * Verify an audit hash (for audit checks — admin only)
 */
export function verifyVoteHash(
  voterId: string,
  electionId: string,
  timestamp: string,
  expectedHash: string
): boolean {
  return generateVoteHash(voterId, electionId, timestamp) === expectedHash
}
