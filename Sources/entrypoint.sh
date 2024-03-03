#!/usr/bin/env bash

echo "aus der Technik - CodeServer"
echo "-----------------------------------------------------------------------------------"
echo ""
echo "Startup Scripts"
if [ -d "/startup" ]; then
  for startupFile in /startup/**.sh; do
  	echo "Execute ${startupFile}"
    "${startupFile}";
  done
fi
echo ""
echo "Starting Code-Server"
code-server \
  --disable-telemetry \
  --extensions-dir /extensions

echo "-----------------------------------------------------------------------------------"
echo "Ready."
echo ""

