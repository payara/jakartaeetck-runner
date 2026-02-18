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
  # Sorted by size (smallest first, based on Client*.java file count)

  # ejb30/lite sub-suites not yet run
  # ejb30/lite/naming          #  1
  # ejb30/lite/xmloverride     #  2
  # ejb30/lite/lookup          #  3
  # ejb30/lite/nointerface     #  3
  # ejb30/lite/enventry        #  4
  # ejb30/lite/view            #  5
  # ejb30/lite/async           #  9
  # ejb30/lite/singleton       #  9
  ejokb30/lite/stateful        #  9
  ejb30/lite/tx              # 14
  ejb30/lite/packaging       # 16

  # Top-level suites (small to large)
  jsonb                      #  1
  jsonp                      #  1
  integration                #  2
  jsp                        #  2
  jta                        #  2
  xa                         #  5
  connector                  #  6
  jacc                       #  6
  el                         #  ~
  javaee                     #  ~
  javamail                   #  ~
  jaxrs                      #  ~
  jaxws                      #  ~
  jdbc                       #  ~
  jstl                       #  ~
  samples                    #  ~
  servlet                    # 17
  appclient                  # 18
  webservices13              # 19
  assembly                   # 27
  ejb32                      # 31
  jms                        # 34
  webservices12              # 77
  jpa                        # 171
  ejb                        # 331

  # Already run (moved to last)
  ejb30/lite/ejbcontext      # 50 tests
  ejb30/lite/basic           # 105 tests
  ejb30/lite/interceptor     # 175 tests
  ejb30/lite/appexception    # 365 tests
  websocket                  # 748 tests
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
