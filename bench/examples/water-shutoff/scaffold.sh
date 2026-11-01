#!/usr/bin/env bash
# Copy this example's files into the run's empty working directory.
set -euo pipefail
cp -R "$(dirname "$0")/files/." .
