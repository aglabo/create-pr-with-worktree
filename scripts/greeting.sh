#!/usr/bin/env bash
#
# @file greeting.sh
# @brief Outputs a greeting message for a given name
# @description
#   This script provides a greeting function that outputs "Hello, <name>!!"
#   Can be used as a standalone script or sourced as a function.
#
# @example
#   ./scripts/greeting.sh "World"
#   # Output: Hello, World!!
#
# @example
#   source ./scripts/greeting.sh
#   greeting "Alice"
#   # Output: Hello, Alice!!

set -euo pipefail

#
# @description Outputs a greeting message
# @arg $1 string Name to greet (required)
# @stdout Greeting message in format "Hello, <name>!!"
# @stderr Error message if name parameter is missing or empty
# @exitcode 0 On success
# @exitcode 1 On error (missing or empty name)
#
greeting() {
  local name="${1:-}"

  if [[ -z "$name" ]]; then
    echo "Error: Name parameter is required" >&2
    return 1
  fi

  echo "Hello, $name!!"
}

#
# @description Main entry point when script is executed directly
# @arg $@ Arguments passed to greeting function
# @exitcode 0 On success
# @exitcode 1 On error
#
main() {
  greeting "$@"
}

# Execute main only if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
