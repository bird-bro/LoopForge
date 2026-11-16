# Execution Contract

## Intent Lock

- **Change name**: hero-anti-overdefense
- **Problem to solve**: Small changes can trigger speculative defensive work or unjustified extra verification.
- **In scope**: Add HERO scope limits to generated root agent files and a Verification Budget to execution contracts.
- **Out of scope**: Removing TDD, security, migration, review, or LoopForge verification gates.

## Approved Behavior

- **Approved requirements summary**: Generated agents receive HERO scope limits; required gates stay authoritative; execution contracts separate required and optional verification.
- **Key scenarios**: Scaffold emits HERO limits; required gates override HERO; optional checks justify themselves; both scaffold variants have regression coverage.
- **Acceptance checks**: OpenSpec validation passes and the LoopForge test suite passes.

## Design Constraints

- **Architecture constraints**: Use existing root agent generation and execution-contract generation paths.
- **Interface constraints**: Keep generated files English-only and compact.
- **Dependency constraints**: No new runtime dependency.
- **Data constraints**: No data schema changes.

## Task Batches

### Batch 1
- **Goal**: Add HERO integration and regression coverage.
- **Input**: OpenSpec artifacts and existing scaffold templates.
- **Output**: Updated scaffold generators, execution-contract generator/template, tests.
- **Completion criteria**: OpenSpec validation and full test suite pass.

## Test Obligations

- **Behaviors requiring failing-test-first**: Missing HERO markers and missing verification budget.
- **Required edge cases**: Both CC and Codex scaffold variants.
- **Regression-sensitive areas**: Root agent generation and contract generation.

## Verification Budget

- **Required verification**: OpenSpec validation and the full LoopForge test suite.
- **Optional checks**: None; no additional check identifies a concrete failure or changed next action.

## Execution Mode

- **Mode**: `Inline`
- **Selection rationale**: Four related tasks with no cross-module dependency.
