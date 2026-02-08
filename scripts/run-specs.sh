#!/usr/bin/env bash
#
# run-specs.sh - Run ShellSpec tests
#
# Usage:
#   ./scripts/run-specs.sh [directory] [shellspec-options]
#
# Arguments:
#   directory          Optional. Test directory for --default-path.
#                      If omitted, uses configs/.shellspecrc default (scripts/__tests__)
#   shellspec-options  Additional ShellSpec options (e.g., --focus, --tag)
#
# Examples:
#   ./scripts/run-specs.sh                    # Use default from config
#   ./scripts/run-specs.sh scripts/__tests__  # Explicit directory
#   ./scripts/run-specs.sh . --focus          # Current dir with focus mode
#

set -euo pipefail

# Get project root
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly SHELLSPEC="${PROJECT_ROOT}/.tools/shellspec/shellspec"
readonly self="${SHELLSPEC}"
readonly SHELLSPEC_CONFIG="${PROJECT_ROOT}/configs/.shellspecrc"


# Run ShellSpec with combined arguments
bash "$SHELLSPEC" --option ${SHELLSPEC_CONFIG} $@
