# Proposal

## Why

Small changes often trigger speculative hashing, defensive scaffolding, checklist churn, or full verification without a concrete failure. LoopForge should make proportionate work the default.

## What Changes

- Add a compact HERO Anti-OverDefense scope-limits section to generated root agent entry files.
- Add a Verification Budget to execution contracts so required checks stay explicit and optional checks must justify themselves.
- Keep all existing TDD, security, migration, review, and LoopForge verification gates authoritative.

## Capabilities

### New Capabilities

- `agent-scope-limits`: Generated agent guidance and contracts that prevent unnecessary defensive work without weakening required verification.

### Modified Capabilities

## Impact

- `skills/loopforge-cc/scaffold.sh`
- `skills/loopforge-codex/scaffold.sh`
- Generated root `AGENTS.md` / `CLAUDE.md`
- Generated execution contracts and the LoopForge regression test suite
