# java-code-upgrade

This is a copy of https://github.com/darshitpp/java-code-upgrade with some adjustments from my side:
1. SKILL.md — Simplified & Script-Free
- Removed all python3 scripts/find-pattern.py execution instructions from Steps 2 and 3
- Replaced with direct Markdown reading: read references/detection-patterns.md for signatures, then read references/{category}.md for the actual transformation details
- Removed report generation references (no assets/upgrade-report-template.md, no "Before/After" report sections)
- Added a ## Dev Tools section noting that dev-tools/ contain upstream sync scripts for maintainers only
- Removed script-specific error handling entries
- Shortened from 107 lines to 97 lines
2. assets/upgrade-report-template.md — Deleted (no longer needed)
3. scripts/ — Restructured
- find-pattern.py → Deleted (runtime script, no longer needed)
- generate-references.py → Moved to dev-tools/generate-references.py
- sync-from-source.sh → Moved to dev-tools/sync-from-source.sh
- The scripts/ directory itself is removed
4. references/detection-patterns.md — Updated
- Now accurately reflects that it's a canonical reference for direct use
- I don't like type inference with `var` and this is excluded.
5. New dev-tools/ Directory
- Houses generate-references.py and sync-from-source.sh for future upstream syncs
- Clearly separated from the runtime skill logic