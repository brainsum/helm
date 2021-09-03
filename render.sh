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
    --validate \
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

# Check for deprecations.
CACHE_DIR="${SCRIPT_DIR}/tmp/.cache"
BIN_DIR="${SCRIPT_DIR}/.bin"
PLUTO_VERSION=5.0.0

mkdir -p "${BIN_DIR}"
mkdir -p "${CACHE_DIR}"

function downloadPluto() {
    curl -L "https://github.com/FairwindsOps/pluto/releases/download/v${PLUTO_VERSION}/pluto_${PLUTO_VERSION}_linux_amd64.tar.gz" \
        -o "${CACHE_DIR}/pluto_${PLUTO_VERSION}_linux_amd64.tar.gz" \
      && tar -xf "${CACHE_DIR}/pluto_${PLUTO_VERSION}_linux_amd64.tar.gz" -C "${CACHE_DIR}" \
      && rm "${CACHE_DIR}/pluto_${PLUTO_VERSION}_linux_amd64.tar.gz" \
      && mv "${CACHE_DIR}/pluto" "${BIN_DIR}/pluto"

    "${BIN_DIR}/pluto" version || exit 1
}

if [ -f "${BIN_DIR}/pluto" ]; then
  "${BIN_DIR}/pluto" version || exit 1
else
  downloadPluto || exit 1
fi

"${BIN_DIR}/pluto" detect-files -owide -d "${SCRIPT_DIR}/.rendered"
