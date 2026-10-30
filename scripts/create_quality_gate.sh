#!/usr/bin/env bash
set -euo pipefail

PROJECT_KEY="${1:-node-quality-tp}"
GATE_NAME="${2:-CESI - NodeJS TP Gate}"

: "${SONAR_HOST_URL:?Env SONAR_HOST_URL is required (e.g., http://localhost:9000)}"
: "${SONAR_TOKEN:?Env SONAR_TOKEN is required (admin token recommended)}"

echo "Creating/ensuring Quality Gate: '$GATE_NAME' at $SONAR_HOST_URL"

cq() { curl -sf -u "$SONAR_TOKEN:" "$@"; }

if cq -X POST "$SONAR_HOST_URL/api/qualitygates/create" --data-urlencode "name=$GATE_NAME" >/dev/null; then
  echo "Gate created."
else
  echo "Gate may already exist. Continuing..."
fi

add_cond() {
  local metric="$1" op="$2" threshold="$3"
  if cq -X POST "$SONAR_HOST_URL/api/qualitygates/add_condition"       --data-urlencode "gateName=$GATE_NAME"       --data-urlencode "metric=$metric"       --data-urlencode "op=$op"       --data-urlencode "error=$threshold" >/dev/null; then
    echo "Condition added: $metric $op $threshold"
  else
    echo "Condition may already exist for $metric. Continuing..."
  fi
}

add_cond new_coverage LT 80
add_cond new_duplicated_lines_density GT 3
add_cond new_security_hotspots_reviewed LT 100
add_cond new_security_rating GT 1
add_cond new_reliability_rating GT 1
add_cond new_maintainability_rating GT 1

if cq -X POST "$SONAR_HOST_URL/api/qualitygates/select"       --data-urlencode "projectKey=$PROJECT_KEY"       --data-urlencode "gateName=$GATE_NAME" >/dev/null; then
  echo "Gate '$GATE_NAME' assigned to project '$PROJECT_KEY'."
else
  echo "Failed to assign gate to project '$PROJECT_KEY' (does the project exist?)."
  exit 1
fi

echo "Done."
