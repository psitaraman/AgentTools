#!/usr/bin/env bash
set -euo pipefail

# check.sh — Automated structural checks for skill grading
# Usage: check.sh <path-to-skill-directory>
# Outputs structured results to stdout for the grading agent to consume.

SKILL_DIR="${1:?Usage: check.sh <path-to-skill-directory>}"

if [[ ! -d "$SKILL_DIR" ]]; then
  echo "ERROR: $SKILL_DIR is not a directory"
  exit 1
fi

SKILL_FILE="$SKILL_DIR/SKILL.md"
if [[ ! -f "$SKILL_FILE" ]]; then
  echo "ERROR: No SKILL.md found in $SKILL_DIR"
  exit 1
fi

echo "═══════════════════════════════════════"
echo "  Automated Skill Check: $(basename "$SKILL_DIR")"
echo "═══════════════════════════════════════"
echo ""

# ─── 1. SKILL.md line count ───
LINE_COUNT=$(wc -l < "$SKILL_FILE")
echo "SKILL.md lines: $LINE_COUNT"
if [[ $LINE_COUNT -lt 200 ]]; then
  echo "  ✅ Under 200 lines"
elif [[ $LINE_COUNT -lt 500 ]]; then
  echo "  ⚠️  Between 200-500 lines (acceptable but could be leaner)"
else
  echo "  ❌ Over 500 lines (too long — split into references)"
fi
echo ""

# ─── 2. Description length ───
# Prefer same-line description (YAML single-line, most common).
# For multi-line YAML block scalars (description: | or description: >),
# read all indented lines following the description: marker until EOF or a
# non-indented line (next top-level YAML key).
DESC=$(grep "^description:" "$SKILL_FILE" | head -1 | sed 's/^description: *//' | sed 's/^"//' | sed 's/"$//' | sed "s/^'//" | sed "s/'$//" || echo "")
if [[ "$DESC" == "|" || "$DESC" == ">" ]]; then
  DESC=$(awk '
    /^description: *[|>]$/ { flag=1; next }
    flag && /^[[:space:]]+/ { sub(/^[[:space:]]+/, ""); print; next }
    flag && /^[^[:space:]]/ { exit }
  ' "$SKILL_FILE" | tr '\n' ' ' | sed 's/[[:space:]]*$//')
fi
if [[ -z "$DESC" ]]; then
  # Last-resort fallback: peek at the single line after description:
  DESC=$(grep -A1 "^description:" "$SKILL_FILE" | tail -1 | sed 's/^[[:space:]]*//' || echo "")
fi
DESC_LEN=${#DESC}
echo "Description length: $DESC_LEN characters"
if [[ $DESC_LEN -eq 0 ]]; then
  echo "  ❌ No description found"
elif [[ $DESC_LEN -le 250 ]]; then
  echo "  ✅ Under 250 characters (fits in truncated listing)"
elif [[ $DESC_LEN -le 1024 ]]; then
  echo "  ⚠️  Over 250 chars but under 1024 (may truncate in listing)"
else
  echo "  ❌ Over 1024 characters (exceeds hard limit on some platforms)"
fi
echo ""

# ─── 3. Directory structure ───
echo "Directory structure:"
HAS_REFERENCES=false
HAS_SCRIPTS=false

if [[ -d "$SKILL_DIR/references" ]]; then
  HAS_REFERENCES=true
  REF_COUNT=$(find "$SKILL_DIR/references" -type f | wc -l)
  echo "  ✅ references/ exists ($REF_COUNT files)"
else
  echo "  ⚠️  No references/ directory"
fi

if [[ -d "$SKILL_DIR/scripts" ]]; then
  HAS_SCRIPTS=true
  SCRIPT_COUNT=$(find "$SKILL_DIR/scripts" -type f | wc -l)
  echo "  ✅ scripts/ exists ($SCRIPT_COUNT files)"
else
  echo "  ⚠️  No scripts/ directory"
fi
echo ""

# ─── 4. Script executability ───
if [[ "$HAS_SCRIPTS" == "true" ]]; then
  echo "Script checks:"
  while IFS= read -r script; do
    BASENAME=$(basename "$script")
    if [[ -x "$script" ]]; then
      echo "  ✅ $BASENAME is executable"
    else
      echo "  ❌ $BASENAME is NOT executable (missing chmod +x)"
    fi
    FIRST_LINE=$(head -1 "$script")
    if echo "$FIRST_LINE" | grep -q "^#!"; then
      echo "  ✅ $BASENAME has shebang: $FIRST_LINE"
    else
      echo "  ❌ $BASENAME has NO shebang"
    fi
  done < <(find "$SKILL_DIR/scripts" -type f)
  echo ""
fi

# ─── 5. Inline content analysis ───
echo "Content analysis:"

# Check for JSON/YAML blocks (potential inline reference material)
JSON_BLOCKS=$(grep -c '```json\|```yaml\|```yml' "$SKILL_FILE" 2>/dev/null) || JSON_BLOCKS=0
if [[ $JSON_BLOCKS -gt 2 ]]; then
  echo "  ⚠️  $JSON_BLOCKS JSON/YAML code blocks found — consider moving to references/"
else
  echo "  ✅ Minimal inline code blocks ($JSON_BLOCKS)"
fi

# Check for example sections (potential inline reference material)
EXAMPLE_LINES=$(grep -c -i "example\|sample\|e\.g\." "$SKILL_FILE" 2>/dev/null) || EXAMPLE_LINES=0
if [[ $EXAMPLE_LINES -gt 10 ]]; then
  echo "  ⚠️  $EXAMPLE_LINES lines reference examples — consider moving to references/"
else
  echo "  ✅ Examples are concise ($EXAMPLE_LINES references)"
fi
echo ""

# ─── 6. Routing checks ───
echo "Routing analysis:"

# Check for references to external files
REF_LINKS=$(grep -c "references/\|scripts/\|CLAUDE_SKILL_DIR" "$SKILL_FILE" 2>/dev/null) || REF_LINKS=0
if [[ $REF_LINKS -gt 0 ]]; then
  echo "  ✅ $REF_LINKS links to external files found"
else
  if [[ "$HAS_REFERENCES" == "true" || "$HAS_SCRIPTS" == "true" ]]; then
    echo "  ❌ References/scripts exist but SKILL.md doesn't link to them"
  else
    echo "  ⚠️  No external file references (skill may be self-contained or monolithic)"
  fi
fi

# Check for context boundary declarations
CONTEXT_REFS=$(grep -c -i "subagent\|current context\|isolated\|context.*fork\|spawn" "$SKILL_FILE" 2>/dev/null) || CONTEXT_REFS=0
if [[ $CONTEXT_REFS -gt 0 ]]; then
  echo "  ✅ $CONTEXT_REFS context boundary references found"
else
  echo "  ⚠️  No context boundary declarations found"
fi

# Check for done signals
DONE_REFS=$(grep -c -i "done when\|complete when\|finished\|done signal\|stop when" "$SKILL_FILE" 2>/dev/null) || DONE_REFS=0
if [[ $DONE_REFS -gt 0 ]]; then
  echo "  ✅ $DONE_REFS completion signals found"
else
  echo "  ⚠️  No explicit done/completion signals found"
fi

# Check for failure handling
FAIL_REFS=$(grep -c -i "fail\|error\|blocked\|fallback\|if.*wrong\|if.*broken" "$SKILL_FILE" 2>/dev/null) || FAIL_REFS=0
if [[ $FAIL_REFS -gt 0 ]]; then
  echo "  ✅ $FAIL_REFS failure/error handling references found"
else
  echo "  ⚠️  No failure handling references found"
fi
echo ""

# ─── 7. Hardcoded content check ───
echo "Domain-agnostic check:"

# Project-specific terms to flag. Override with a .skill-check-terms file (one term per line)
# next to check.sh, or set SKILL_CHECK_TERMS env var (pipe-separated: "term1|term2|term3")
TERMS_FILE="$(dirname "${BASH_SOURCE[0]}")/.skill-check-terms"
if [[ -n "${SKILL_CHECK_TERMS:-}" ]]; then
  DOMAIN_PATTERN="${SKILL_CHECK_TERMS}"
elif [[ -f "$TERMS_FILE" ]]; then
  DOMAIN_PATTERN=$(paste -sd '|' "$TERMS_FILE")
else
  DOMAIN_PATTERN=""
fi

if [[ -n "$DOMAIN_PATTERN" ]]; then
  HARDCODED=$(grep -c -i "$DOMAIN_PATTERN" "$SKILL_FILE" 2>/dev/null) || HARDCODED=0
  if [[ $HARDCODED -gt 0 ]]; then
    echo "  ⚠️  $HARDCODED project-specific references found — may not be domain-agnostic"
  else
    echo "  ✅ No project-specific references found"
  fi
else
  echo "  ⚠️  No domain terms configured — skipping. Add .skill-check-terms or set SKILL_CHECK_TERMS"
  HARDCODED="N/A"
fi
echo ""

# ─── Summary ───
echo "═══════════════════════════════════════"
echo "  Summary"
echo "═══════════════════════════════════════"
echo "  Lines: $LINE_COUNT"
echo "  Description: $DESC_LEN chars"
echo "  References dir: $HAS_REFERENCES"
echo "  Scripts dir: $HAS_SCRIPTS"
echo "  External links: $REF_LINKS"
echo "  Context boundaries: $CONTEXT_REFS"
echo "  Done signals: $DONE_REFS"
echo "  Failure handling: $FAIL_REFS"
echo "  Hardcoded content: $HARDCODED"
echo "═══════════════════════════════════════"
