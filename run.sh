#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/" >/dev/null 2>&1 && pwd)"

mkdir -p "${SCRIPT_DIR}/Project"
SCRIPT_DIR=${SCRIPT_DIR} FOLDER="${PWD}/Project" docker-compose \
    -f "${SCRIPT_DIR}/docker-compose.yaml" \
    --env-file "${SCRIPT_DIR}/.env" \
    up \
    --detach --wait \
    codebook

  sleep 2
  if [ "$(uname -s)" == "Darwin" ]; then
    open http://localhost:31546/?folder=/project
  else
    which xdg-open && true
    if [ "$?" == "0" ]; then
      xdg-open http://localhost:31546/?folder=/project
    else 
      echo "Open http://localhost:31546/?folder=/project in your browser."
    fi
  fi
  echo ""
  echo "Press enter to stop the code-server."
  read -r
  docker-compose -f "${SCRIPT_DIR}/docker-compose.yaml" down codebook
  