#!/bin/bash
#
# Runs each TCK suite individually and saves logs to a specified output directory.
#
# Usage:
#   ./run_all.sh [output_dir]
#
# If output_dir is not specified, logs are saved to ./results/logs/

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
OUTPUT_DIR="${1:-$SCRIPTPATH/results/logs}"
mkdir -p "$OUTPUT_DIR"

SUITES=(
  # Top-level suites
  appclient
  assembly
  connector
  ejb
  ejb32
  el
  integration
  jacc
  javaee
  javamail
  jaxrs
  jaxws
  jdbc
  jms
  jpa
  jsonb
  jsonp
  jsp
  jstl
  jta
  samples
  servlet
  webservices12
  webservices13
  websocket
  xa

  # ejb30/lite sub-suites
  ejb30/lite/appexception
  ejb30/lite/async
  ejb30/lite/basic
  ejb30/lite/ejbcontext
  ejb30/lite/enventry
  ejb30/lite/interceptor
  ejb30/lite/lookup
  ejb30/lite/naming
  ejb30/lite/nointerface
  ejb30/lite/packaging
  ejb30/lite/singleton
  ejb30/lite/stateful
  ejb30/lite/tx
  ejb30/lite/view
  ejb30/lite/xmloverride
)

TOTAL=${#SUITES[@]}
CURRENT=0

for suite in "${SUITES[@]}"; do
  CURRENT=$((CURRENT + 1))
  # Convert slashes to underscores for the filename
  filename=$(echo "$suite" | tr '/' '_')
  logfile="$OUTPUT_DIR/local-${filename}.txt"

  echo "========================================"
  echo "[$CURRENT/$TOTAL] Running: $suite"
  echo "  Log: $logfile"
  echo "========================================"

  "$SCRIPTPATH/run.sh" "$suite" > "$logfile" 2>&1

  # Extract the result from the log
  result=$(grep "Failed Count:" "$logfile" | tail -1)
  if [ -n "$result" ]; then
    echo "  Result: $result"
  else
    echo "  Result: No summary found (tests may not have run)"
  fi
  echo ""
done

echo "========================================"
echo "All suites finished. Summary:"
echo "========================================"
for suite in "${SUITES[@]}"; do
  filename=$(echo "$suite" | tr '/' '_')
  logfile="$OUTPUT_DIR/local-${filename}.txt"
  result=$(grep "Failed Count:" "$logfile" 2>/dev/null | tail -1)
  printf "  %-35s %s\n" "$suite" "${result:-NO RESULT}"
done
