#!/usr/bin/env bash

# @file: Helper script for rendering the chart into a local directory.
#

SCRIPT=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT")


PROJECT=helmdemo
CHART="drupal"
CHART_PATH="${SCRIPT_DIR}/charts/${CHART}"

ENVIRONMENTS='staging production'

for ENVIRONMENT in ${ENVIRONMENTS}
do
  VALUE_FILE="${SCRIPT_DIR}/.rendervalues/${CHART}/${ENVIRONMENT}/values.yaml"
  OUTPUT_DIR="${SCRIPT_DIR}/.rendered/${CHART}/${ENVIRONMENT}"
  RELEASE_NAME="${PROJECT}-${ENVIRONMENT}"

  echo "Rendering to ${OUTPUT_DIR}"
  [ -d "${OUTPUT_DIR}" ] && rm -r "${OUTPUT_DIR}"
  helm template "${RELEASE_NAME}" "${CHART_PATH}" \
    -f "${VALUE_FILE}" \
    --output-dir "${OUTPUT_DIR}" \
    --debug
done


# ----------------------- #
CHART="tika-server"
CHART_PATH="${SCRIPT_DIR}/charts/${CHART}"
OUTPUT_DIR="${SCRIPT_DIR}/.rendered/${CHART}"
VALUE_FILE="${SCRIPT_DIR}/.rendervalues/${CHART}/values.yaml"
OUTPUT_DIR="${SCRIPT_DIR}/.rendered/${CHART}"
RELEASE_NAME="${PROJECT}"

#     -f "${VALUE_FILE}" \
helm template "${RELEASE_NAME}" "${CHART_PATH}" \
    --output-dir "${OUTPUT_DIR}" \
    --debug
