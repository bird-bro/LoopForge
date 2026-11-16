# Spec Delta

## Purpose

Define the HERO scope limits emitted by LoopForge so generated agents reduce speculative defensive work while preserving required verification gates.

## ADDED Requirements

### Requirement: Generated agent scope limits

LoopForge scaffold SHALL emit an English `HERO Scope Limits` section into root `AGENTS.md` and `CLAUDE.md` for newly generated projects.

#### Scenario: Scaffold emits HERO limits

- **WHEN** either LoopForge scaffold generates a new project
- **THEN** root `AGENTS.md` and `CLAUDE.md` contain the HERO Scope Limits section
- **AND** the section states that fixes are limited to cases reachable through supported use

### Requirement: Required gates remain authoritative

The HERO section SHALL explicitly preserve user requirements, project conventions, higher-priority rules, security, migration, verification, review, and LoopForge TDD gates.

#### Scenario: HERO does not remove required verification

- **WHEN** generated agent files contain the HERO section
- **THEN** the section states that required gates override HERO limits

### Requirement: Execution contract verification budget

The execution-contract template and generated contracts SHALL include a `Verification Budget` that separates required verification from optional checks.

#### Scenario: Optional check must justify itself

- **WHEN** an agent considers an optional check
- **THEN** it must identify the concrete failure the check detects and the action that would change if the failure occurred
- **AND** it must not run the check solely to add confidence

### Requirement: Regression coverage

The LoopForge test suite SHALL verify that both scaffold variants emit HERO scope limits and execution-contract verification budgets.

#### Scenario: Regression test covers both generators

- **WHEN** the LoopForge test suite runs
- **THEN** it asserts the markers in generated root agent files and generated execution contracts for both LoopForge scaffold variants
