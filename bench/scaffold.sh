#!/usr/bin/env bash
# Copy the fixture project into the run's empty working directory.
# `claude plugin eval` runs this before each session, through the scaffold.sh
# link in each task's folder.
set -euo pipefail
cp -R "$(dirname "$(realpath "$0")")/world/." .
