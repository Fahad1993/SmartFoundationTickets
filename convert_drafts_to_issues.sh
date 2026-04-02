#!/usr/bin/env bash
# convert_drafts_to_issues.sh
#
# Converts every Draft item in GitHub Project #3 into a real GitHub Issue
# inside the Fahad1993/SmartFoundationTickets repository.
#
# For each draft the script will:
#   1. Create a GitHub Issue with the exact same title and body.
#   2. Add the new issue to the project.
#   3. Copy the draft's Status column value onto the new project item.
#   4. Delete the original draft item.
#
# Requirements:
#   - gh CLI authenticated with a classic token that has 'repo' and 'project' scopes.
#   - jq 1.6+ installed.
#
# Usage:
#   GH_TOKEN=<ghp_...> bash convert_drafts_to_issues.sh
#
# Dry-run (lists drafts but makes no changes):
#   DRY_RUN=1 GH_TOKEN=<ghp_...> bash convert_drafts_to_issues.sh

set -euo pipefail

OWNER="Fahad1993"
REPO="SmartFoundationTickets"
PROJECT_NUMBER=3
DRY_RUN="${DRY_RUN:-0}"

echo "==========================================="
echo " Draft → Issue Converter"
echo " Project : #${PROJECT_NUMBER}  Owner: ${OWNER}"
echo " Repo    : ${REPO}"
[[ "$DRY_RUN" == "1" ]] && echo " Mode    : DRY RUN (no changes will be made)"
echo "==========================================="
echo ""

# ---------------------------------------------------------------------------
# Step 1: Fetch project node ID and Status field metadata (one GraphQL call)
# ---------------------------------------------------------------------------
echo "Fetching project metadata..."
PROJECT_META=$(gh api graphql -f query='
  query($login: String!, $number: Int!) {
    user(login: $login) {
      projectV2(number: $number) {
        id
        fields(first: 30) {
          nodes {
            ... on ProjectV2SingleSelectField {
              id
              name
              options { id name }
            }
          }
        }
      }
    }
  }' \
  -f login="$OWNER" \
  -F number="$PROJECT_NUMBER")

PROJECT_ID=$(echo "$PROJECT_META" | jq -r '.data.user.projectV2.id')
STATUS_FIELD_ID=$(echo "$PROJECT_META" | jq -r '
  .data.user.projectV2.fields.nodes[]
  | select(.name == "Status")
  | .id // empty')

echo "  Project node ID  : ${PROJECT_ID}"
echo "  Status field ID  : ${STATUS_FIELD_ID:-<not found>}"
echo ""

# Helper: resolve a status display name to its option node ID
get_option_id() {
  local status_name="$1"
  echo "$PROJECT_META" | jq -r --arg name "$status_name" '
    .data.user.projectV2.fields.nodes[]
    | select(.name == "Status")
    | .options[]
    | select(.name == $name)
    | .id // empty'
}

# ---------------------------------------------------------------------------
# Step 2: List all project items (up to 500; adjust --limit if needed)
# ---------------------------------------------------------------------------
echo "Fetching project items..."
ITEMS_JSON=$(gh project item-list "$PROJECT_NUMBER" \
  --owner "$OWNER" \
  --format json \
  --limit 500)

TOTAL_ITEMS=$(echo "$ITEMS_JSON" | jq '.items | length')
DRAFT_COUNT=$(echo "$ITEMS_JSON" | jq '[.items[] | select(.type == "DraftIssue")] | length')

echo "  Total items in project : ${TOTAL_ITEMS}"
echo "  Draft items to convert : ${DRAFT_COUNT}"
echo ""

if [[ "$DRAFT_COUNT" -eq 0 ]]; then
  echo "No draft items found. Nothing to do."
  exit 0
fi

# ---------------------------------------------------------------------------
# Step 3: Convert each draft
# ---------------------------------------------------------------------------
CONVERTED=0
FAILED=0
IDX=0

for i in $(seq 0 $((TOTAL_ITEMS - 1))); do
  ITEM=$(echo "$ITEMS_JSON" | jq -c ".items[$i]")
  ITEM_TYPE=$(echo "$ITEM" | jq -r '.type')

  [[ "$ITEM_TYPE" != "DraftIssue" ]] && continue

  IDX=$((IDX + 1))
  DRAFT_ID=$(echo "$ITEM" | jq -r '.id')
  TITLE=$(echo "$ITEM"    | jq -r '.title')
  BODY=$(echo "$ITEM"     | jq -r '.body // ""')
  STATUS=$(echo "$ITEM"   | jq -r '.status // ""')

  echo "[${IDX}/${DRAFT_COUNT}] ${TITLE}"

  if [[ "$DRY_RUN" == "1" ]]; then
    echo "  (dry-run) Would create issue, add to project, set status: '${STATUS}', delete draft."
    continue
  fi

  # -- 3a. Create the GitHub Issue ------------------------------------------
  CREATE_OUTPUT=$(gh issue create \
    --repo "${OWNER}/${REPO}" \
    --title "$TITLE" \
    --body "$BODY" 2>&1) || true

  ISSUE_URL=$(echo "$CREATE_OUTPUT" | grep -E "^https://github\.com/" | tail -1)

  if [[ -z "$ISSUE_URL" ]]; then
    echo "  ERROR: issue creation failed — skipping this draft."
    echo "         Output: ${CREATE_OUTPUT}"
    FAILED=$((FAILED + 1))
    continue
  fi

  echo "  Issue created  : ${ISSUE_URL}"

  # -- 3b. Add the issue to the project ------------------------------------
  ADD_RESULT=$(gh project item-add "$PROJECT_NUMBER" \
    --owner "$OWNER" \
    --url "$ISSUE_URL" \
    --format json)

  NEW_ITEM_ID=$(echo "$ADD_RESULT" | jq -r '.id')
  echo "  Project item   : ${NEW_ITEM_ID}"

  # -- 3c. Copy the Status column value ------------------------------------
  if [[ -n "$STATUS" && -n "${STATUS_FIELD_ID:-}" ]]; then
    OPTION_ID=$(get_option_id "$STATUS")
    if [[ -n "$OPTION_ID" ]]; then
      if gh project item-edit \
          --id "$NEW_ITEM_ID" \
          --project-id "$PROJECT_ID" \
          --field-id "$STATUS_FIELD_ID" \
          --single-select-option-id "$OPTION_ID"; then
        echo "  Status set     : ${STATUS}"
      else
        echo "  WARNING: failed to set status '${STATUS}' — issue was still created."
      fi
    else
      echo "  WARNING: status option '${STATUS}' not found in project fields — skipped."
    fi
  fi

  # -- 3d. Delete the original draft ---------------------------------------
  if gh project item-delete "$PROJECT_NUMBER" \
      --owner "$OWNER" \
      --id "$DRAFT_ID"; then
    echo "  Draft deleted."
  else
    echo "  WARNING: failed to delete draft item ${DRAFT_ID} — it may still appear in the project."
  fi
  CONVERTED=$((CONVERTED + 1))

  # Small pause to stay well within GitHub API rate limits
  sleep 0.5
done

echo ""
echo "==========================================="
echo " Conversion complete!"
echo " Converted : ${CONVERTED}"
echo " Failed    : ${FAILED}"
echo " Board URL : https://github.com/users/${OWNER}/projects/${PROJECT_NUMBER}"
echo "==========================================="
