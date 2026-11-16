# Design

## Decisions

- Emit HERO guidance only in root agent files to avoid duplicating the same rule in per-stack agent files for the same tool.
- Use a compact English block with explicit precedence: required gates override HERO.
- Add Verification Budget to the contract template and direct contract generator, not as a new script.
- Assert both the text block and contract marker in the existing test suite.
