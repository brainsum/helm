#!/usr/bin/env bash

# @file: Helper script for packaging the chart into docs

SCRIPT=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT")

CHARTS='drupal tika-server'

LINT_ERRORS=false

for CHART in ${CHARTS}
do
  helm lint --debug "${SCRIPT_DIR}/charts/${CHART}" || LINT_ERRORS=true
done

if [ "$LINT_ERRORS" = true ] ; then
  echo ""
  echo "One or more charts are invalid, please fix them!"
  exit 1
fi

for CHART in ${CHARTS}
do
  helm package "${SCRIPT_DIR}/charts/${CHART}" -d "${SCRIPT_DIR}/docs"
done

helm repo index docs --url https://brainsum.github.io/helm/
