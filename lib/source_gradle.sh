#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
# Treat unset variables as an error when substituting.
set -eu

gradle_home="${GRADLE_USER_HOME:-$HOME/.gradle}"
gradle_properties_file="$gradle_home/gradle.properties"

if [ ! -f "$gradle_properties_file" ]; then
  echo "ERROR: File $gradle_properties_file does not exist. Cannot source gradle"
  exit 1
fi

echo "Found 'gradle.properties' file at $gradle_properties_file"

function prop {
    grep "${1}" "${gradle_properties_file}" | cut -d'=' -f2
}

export repository_username="$(prop kitpvpWorldRepositoryUsername)"
export repository_password="$(prop kitpvpWorldRepositoryPassword)"

echo "Authenticated as '${repository_username}'"
echo "Saved credentials to environment variables (repository_username, repository_password)"
