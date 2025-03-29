#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
# Treat unset variables as an error when substituting.
set -eu

downloadHash="49b2b1a1408b6a3bc71cde227fb16d00c558cda4"
downloadUrl="https://maven.kitpvp.world/snapshots/world/kitpvp/translation-compiler/${downloadHash}/translation-compiler-linux-x64"
outputFile="bin/translation-compiler-${downloadHash}"

if [ -e "${outputFile}" ]; then
    echo "INFO: '${outputFile}' binary is already present."
    exit 0
fi

echo "INFO: Cleaning up old files"
rm -f bin/*
mkdir -p bin

echo "INFO: Preparing to download from URL: ${downloadUrl}"

if [ -z "${repository_username:-}" ]; then
  if [ -n "${REPO_KITPVP_USERNAME:-}" ]; then
    export repository_username="${REPO_KITPVP_USERNAME}"
  else
    echo "ERROR: 'repository_username' is not set, and fallback 'REPO_KITPVP_USERNAME' is also not set or empty." >&2
    exit 1 # Exit with an error
  fi
fi

if [ -z "${repository_password:-}" ]; then
  if [ -n "${REPO_KITPVP_PASSWORD:-}" ]; then
    export repository_password="${REPO_KITPVP_PASSWORD}"
  else
    echo "ERROR: 'repository_password' is not set, and fallback 'REPO_KITPVP_PASSWORD' is also not set or empty." >&2
    exit 1 # Exit with an error
  fi
fi

curl -L -f -u "${repository_username}:${repository_password}" -o "${outputFile}" "${downloadUrl}"
