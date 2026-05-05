#!/usr/bin/env bash
set -euo pipefail

# check-phase.sh — Verify phase artifacts exist and are valid before proceeding
# Usage: check-phase.sh <phase-number> <feature-path>
# Example: check-phase.sh 3 my-product/features/login
# Outputs structured results to stdout for the orchestrator to consume.

PHASE="${1:?Usage: check-phase.sh <phase-number> <feature-path>}"
FEATURE_PATH="${2:?Usage: check-phase.sh <phase-number> <feature-path>}"

if [[ ! -d "$FEATURE_PATH" ]]; then
  echo "ERROR: $FEATURE_PATH is not a directory"
  exit 1
fi

echo "========================================="
echo "  Phase $PHASE Pre-Check: $(basename "$FEATURE_PATH")"
echo "========================================="
echo ""

ERRORS=0

# --- Helper functions ---

check_file_exists() {
  local file="$1"
  local label="$2"
  if [[ -f "$file" ]]; then
    echo "  PASS: $label exists"
  else
    echo "  FAIL: $label MISSING: $file"
    ERRORS=$((ERRORS + 1))
  fi
}

check_not_stale() {
  local file="$1"
  local label="$2"
  if [[ ! -f "$file" ]]; then
    return
  fi
  if grep -q "status: stale" "$file" 2>/dev/null; then
    echo "  FAIL: $label is STALE — must be regenerated before use"
    ERRORS=$((ERRORS + 1))
  else
    echo "  PASS: $label is not stale"
  fi
}

check_has_version() {
  local file="$1"
  local label="$2"
  if [[ ! -f "$file" ]]; then
    return
  fi
  if grep -q "^version:" "$file" 2>/dev/null; then
    local version
    version=$(grep "^version:" "$file" | head -1 | sed 's/version: *//')
    echo "  PASS: $label has version: $version"
  else
    echo "  FAIL: $label has NO version frontmatter"
    ERRORS=$((ERRORS + 1))
  fi
}

check_dir_has_files() {
  local dir="$1"
  local label="$2"
  local pattern="${3:-*}"
  if [[ ! -d "$dir" ]]; then
    echo "  FAIL: $label directory MISSING: $dir"
    ERRORS=$((ERRORS + 1))
    return
  fi
  local count
  count=$(find "$dir" -type f -name "$pattern" 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$count" -gt 0 ]]; then
    echo "  PASS: $label exists ($count files)"
  else
    echo "  FAIL: $label directory exists but contains no matching files"
    ERRORS=$((ERRORS + 1))
  fi
}

check_tests_readonly() {
  local test_dir="$1"
  if [[ ! -d "$test_dir" ]]; then
    return
  fi
  # Portable check: test each file for writability
  local writable_count=0
  while IFS= read -r f; do
    if [[ -w "$f" ]]; then
      writable_count=$((writable_count + 1))
    fi
  done < <(find "$test_dir" -type f 2>/dev/null)
  if [[ "$writable_count" -gt 0 ]]; then
    echo "  FAIL: $writable_count test file(s) are writable — should be read-only"
    ERRORS=$((ERRORS + 1))
  else
    echo "  PASS: Test files are read-only"
  fi
}

# --- Phase-specific checks ---

echo "Required artifacts:"

case "$PHASE" in
  1)
    echo "  Phase 1 is the root — no input artifacts required."
    echo ""
    ;;
  2)
    # Version frontmatter is enforced at the phase where each artifact first
    # appears as an input: product-spec here, tech-spec at Phase 3, BDD files
    # at Phase 4, checklists at Phase 5. Per `document-hierarchy.md`, every
    # pipeline document carries its own `version:` field.
    check_file_exists "$FEATURE_PATH/product-spec.md" "Product spec"
    check_not_stale "$FEATURE_PATH/product-spec.md" "Product spec"
    check_has_version "$FEATURE_PATH/product-spec.md" "Product spec"
    echo ""
    ;;
  3)
    check_file_exists "$FEATURE_PATH/product-spec.md" "Product spec"
    check_not_stale "$FEATURE_PATH/product-spec.md" "Product spec"
    check_file_exists "$FEATURE_PATH/tech-spec.md" "Tech spec"
    check_not_stale "$FEATURE_PATH/tech-spec.md" "Tech spec"
    check_has_version "$FEATURE_PATH/tech-spec.md" "Tech spec"
    echo ""
    ;;
  4)
    check_file_exists "$FEATURE_PATH/product-spec.md" "Product spec"
    check_not_stale "$FEATURE_PATH/product-spec.md" "Product spec"
    check_file_exists "$FEATURE_PATH/tech-spec.md" "Tech spec"
    check_not_stale "$FEATURE_PATH/tech-spec.md" "Tech spec"
    check_dir_has_files "$FEATURE_PATH/bdd" "BDD scenarios" "*.md"
    # Verify each BDD file has version frontmatter (first phase where BDD is input)
    for bdd_file in "$FEATURE_PATH"/bdd/*.md; do
      [[ -f "$bdd_file" ]] && check_has_version "$bdd_file" "BDD $(basename "$bdd_file")"
    done
    echo ""
    ;;
  5)
    check_file_exists "$FEATURE_PATH/tech-spec.md" "Tech spec"
    check_not_stale "$FEATURE_PATH/tech-spec.md" "Tech spec"
    check_dir_has_files "$FEATURE_PATH/bdd" "BDD scenarios" "*.md"
    # Check checklists exist (generated in Phase 4)
    check_dir_has_files "$FEATURE_PATH/checklists" "Evaluation checklists" "*.md"
    # Verify each checklist has version frontmatter (first phase where checklists are input)
    for cl_file in "$FEATURE_PATH"/checklists/*.md; do
      [[ -f "$cl_file" ]] && check_has_version "$cl_file" "Checklist $(basename "$cl_file")"
    done
    echo ""
    ;;
  6)
    check_file_exists "$FEATURE_PATH/product-spec.md" "Product spec"
    check_not_stale "$FEATURE_PATH/product-spec.md" "Product spec"
    check_file_exists "$FEATURE_PATH/tech-spec.md" "Tech spec"
    check_not_stale "$FEATURE_PATH/tech-spec.md" "Tech spec"
    check_dir_has_files "$FEATURE_PATH/bdd" "BDD scenarios" "*.md"
    check_dir_has_files "$FEATURE_PATH/tests" "Test files"
    check_tests_readonly "$FEATURE_PATH/tests"
    echo ""
    ;;
  7)
    check_file_exists "$FEATURE_PATH/product-spec.md" "Product spec"
    check_not_stale "$FEATURE_PATH/product-spec.md" "Product spec"
    check_file_exists "$FEATURE_PATH/tech-spec.md" "Tech spec"
    check_not_stale "$FEATURE_PATH/tech-spec.md" "Tech spec"
    check_dir_has_files "$FEATURE_PATH/bdd" "BDD scenarios" "*.md"
    check_dir_has_files "$FEATURE_PATH/tests" "Test files"
    check_dir_has_files "$FEATURE_PATH/checklists" "Evaluation checklists" "*.md"
    check_tests_readonly "$FEATURE_PATH/tests"
    echo "  Verify: all TDD tests passing before branch review."
    echo ""
    ;;
  8)
    echo "  Phase 8 operates on the full trunk after a branch merge."
    echo "  Verify: feature branch merged to trunk."
    echo ""
    ;;
  9)
    echo "  Phase 9 operates on the full trunk + running application."
    echo "  Verify: all branches merged, no open branches, app starts."
    echo ""
    ;;
  *)
    echo "  ERROR: Unknown phase $PHASE (valid: 1-9)"
    exit 1
    ;;
esac

# --- Test integrity check (Phases 6-9) ---

if [[ "$PHASE" -ge 6 && -d "$FEATURE_PATH/tests" ]]; then
  echo "Test integrity:"
  if [[ -f "$FEATURE_PATH/tests/.baseline" ]]; then
    local_modified=$(find "$FEATURE_PATH/tests" -type f -newer "$FEATURE_PATH/tests/.baseline" ! -name ".baseline" 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$local_modified" -gt 0 ]]; then
      echo "  FAIL: $local_modified test file(s) modified since Phase 5 baseline"
      ERRORS=$((ERRORS + 1))
    else
      echo "  PASS: Test files unmodified since baseline"
    fi
  else
    echo "  FAIL: No .baseline file found — test integrity cannot be verified."
    echo "        The harness must write tests/.baseline at the end of Phase 5."
    ERRORS=$((ERRORS + 1))
  fi
  echo ""
fi

# --- Summary ---

echo "========================================="
if [[ $ERRORS -eq 0 ]]; then
  echo "  PASS — Phase $PHASE pre-checks passed"
else
  echo "  FAIL — $ERRORS error(s) found. Resolve before proceeding."
fi
echo "========================================="

exit $ERRORS
