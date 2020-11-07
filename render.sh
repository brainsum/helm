#!/usr/bin/env bash

# @file: Helper script for rendering the chart into a local directory.
#

SCRIPT=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT")


PROJECT=helmdemo
CHART="${SCRIPT_DIR}/charts/drupal"

ENVIRONMENTS='staging production'

for ENVIRONMENT in ${ENVIRONMENTS}
do
  VALUE_FILE="${SCRIPT_DIR}/tmp/values/${ENVIRONMENT}/values.yaml"
  OUTPUT_DIR="${SCRIPT_DIR}/rendered/${ENVIRONMENT}"
  RELEASE_NAME="${PROJECT}-${ENVIRONMENT}"

  echo "Rendering to ${OUTPUT_DIR}"
  [ -d "${OUTPUT_DIR}" ] && rm -r "${OUTPUT_DIR}"
  helm template "${RELEASE_NAME}" "${CHART}" \
    -f "${VALUE_FILE}" \
    --output-dir "${OUTPUT_DIR}" \
    --debug
done
