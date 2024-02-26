#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/" >/dev/null 2>&1 && pwd)"

SCRIPT_DIR=${SCRIPT_DIR} docker-compose \
    -f "${SCRIPT_DIR}/docker-compose.yaml" \
    --env-file "${SCRIPT_DIR}/.env" \
    build \
    codebook

# --no-cache 

