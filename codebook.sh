#!/usr/bin/env bash

#
# Setup script to run CodeBook on current folder
#
# curl https://raw.githubusercontent.com/KrisSimon/CodeBook/main/codebook.sh | sh -
#

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/" >/dev/null 2>&1 && pwd)"
curl https://raw.githubusercontent.com/KrisSimon/CodeBook/main/.env >> .env
mkdir -p "${SCRIPT_DIR}/CodeBook"
if [ ! -f "${SCRIPT_DIR}/docker-compose.yaml" ]; then
  curl https://raw.githubusercontent.com/KrisSimon/CodeBook/main/docker-compose.yaml >> "${SCRIPT_DIR}/docker-compose.yaml"
fi
if [ ! -f "${SCRIPT_DIR}/settings.json" ]; then
  curl https://raw.githubusercontent.com/KrisSimon/CodeBook/main/settings.json >> "${SCRIPT_DIR}/settings.json"
fi


SCRIPT_DIR=${SCRIPT_DIR} docker-compose \
    -f "${SCRIPT_DIR}/docker-compose.yaml" \
    --env-file "${SCRIPT_DIR}/.env" \
    up \
    --detach --wait \
    codebook

  sleep 2
  if [ "$(uname -s)" == "Darwin" ]; then
    open http://localhost:8080/?folder=/project
  else
    which xdg-open && true
    if [ "$?" == "0" ]; then
      xdg-open http://localhost:8080/?folder=/project
    else 
      echo "Open http://localhost:8080/?folder=/project in your browser."
    fi
  fi
  echo ""
  echo "Press enter to stop the code-server."
  read -r
  docker-compose -f "${SCRIPT_DIR}/docker-compose.yaml" down codebook
  