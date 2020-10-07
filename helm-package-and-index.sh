#!/usr/bin/env bash

# @file: Helper script for packaging the chart into docs

SCRIPT=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT")

CHART=drupal

helm package "${SCRIPT_DIR}/charts/${CHART}" -d "${SCRIPT_DIR}/docs"

helm repo index docs --url https://brainsum.github.io/helm/
