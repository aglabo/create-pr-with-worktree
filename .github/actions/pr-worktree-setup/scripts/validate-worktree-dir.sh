#!/usr/bin/env bash
# src: ./.github/actions/pr-worktree-setup/scripts/validate-worktree-dir.sh
# @(#) : Validate gitsign installation and OIDC environment
#
# Copyright (c) 2026- aglabo <https://github.com/aglabo>
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT
#
# @file validate-worktree-dir.sh
# @brief Validate and normalize worktree directory path
# @description
#   Validates worktree directory input and constructs the final path.
#   - If input is absolute path: use as-is
#   - If input is relative path: prepend RUNNER_TEMP
#   - Validates path safety (no path traversal, no dangerous characters)
#
# @arg $1 string worktree-dir input from action
# @arg $2 string RUNNER_TEMP directory
# @arg $3 string github.run-id for uniqueness
#
# @exitcode 0 Validation successful
# @exitcode 1 Validation failed
#
# @stdout Validation messages
# @set GITHUB_OUTPUT Writes worktree-dir, worktree-parent, status, message
#
# @author atsushifx
# @version 1.0.0
# @license MIT

set -euo pipefail

# Safe output file handling
GITHUB_OUTPUT_FILE="${GITHUB_OUTPUT:-/dev/null}"

# Input parameters
WORKTREE_INPUT="$1"
RUNNER_TEMP="${2:-}"
RUN_ID="${3:-}"

# ============================================================================
# Validation Functions
# ============================================================================

# @description Check if path is absolute
# @arg $1 string Path to check
# @exitcode 0 Path is absolute
# @exitcode 1 Path is relative
is_absolute_path() {
  local path="$1"

  # Use case statement for clarity and POSIX compatibility
  case "$path" in
    /*)
      # Unix/Linux absolute path
      return 0
      ;;
    [A-Za-z]:*)
      # Windows absolute path (C:\path or C:/path)
      return 0
      ;;
    *)
      # Relative path
      return 1
      ;;
  esac
}

# @description Validate path for safety
# @arg $1 string Path to validate
# @exitcode 0 Path is safe
# @exitcode 1 Path contains dangerous patterns
validate_path_safety() {
  local path="$1"

  # Check for path traversal (..)
  if [[ "$path" == *".."* ]]; then
    echo "::error::Path cannot contain '..' sequences (path traversal)" >&2
    echo "::error::Got: ${path}" >&2
    return 1
  fi

  # Check for current directory reference at start (./path) or end (path/.)
  # Allow dots in filenames like "v1.2.0" or "issue-3.14"
  if [[ "$path" == "./"* ]] || [[ "$path" == *"/." ]] || [[ "$path" == "." ]]; then
    echo "::error::Path cannot start with './', end with '/.', or be '.'" >&2
    echo "::error::Got: ${path}" >&2
    return 1
  fi

  # Check for path segments that are exactly "." (e.g., "path/./file")
  if [[ "$path" == *"/."/* ]] || [[ "$path" == *"/./"* ]]; then
    echo "::error::Path cannot contain '/./' sequences" >&2
    echo "::error::Got: ${path}" >&2
    return 1
  fi

  # Path is safe (newlines and null bytes cannot exist in bash variables from normal input)
  return 0
}

# ============================================================================
# Main Logic
# ============================================================================

echo "=== Worktree Directory Validation ==="
echo ""
echo "Input: ${WORKTREE_INPUT}"

# Validate input is not empty
if [ -z "$WORKTREE_INPUT" ]; then
  echo "::error::worktree-dir cannot be empty"
  {
    echo "status=error"
    echo "message=worktree-dir input is empty"
  } >> "$GITHUB_OUTPUT_FILE"
  exit 1
fi

# Validate path safety
if ! validate_path_safety "$WORKTREE_INPUT"; then
  {
    echo "status=error"
    echo "message=Invalid path: contains dangerous patterns"
  } >> "$GITHUB_OUTPUT_FILE"
  exit 1
fi

# Determine final path based on absolute/relative
if is_absolute_path "$WORKTREE_INPUT"; then
  # Absolute path: use as-is
  echo "✓ Detected absolute path"

  if [ -n "$RUN_ID" ]; then
    WORKTREE_DIR="${WORKTREE_INPUT}-${RUN_ID}"
  else
    WORKTREE_DIR="${WORKTREE_INPUT}"
  fi

  WORKTREE_PARENT="$WORKTREE_INPUT"

else
  # Relative path: prepend RUNNER_TEMP
  echo "✓ Detected relative path"

  if [ -z "$RUNNER_TEMP" ]; then
    echo "::error::RUNNER_TEMP is required for relative paths"
    {
      echo "status=error"
      echo "message=RUNNER_TEMP not provided for relative path"
    } >> "$GITHUB_OUTPUT_FILE"
    exit 1
  fi

  if [ -n "$RUN_ID" ]; then
    WORKTREE_DIR="${RUNNER_TEMP}/${WORKTREE_INPUT}-${RUN_ID}"
  else
    WORKTREE_DIR="${RUNNER_TEMP}/${WORKTREE_INPUT}"
  fi

  WORKTREE_PARENT="${RUNNER_TEMP}/${WORKTREE_INPUT}"
fi

# Validate final paths
if ! validate_path_safety "$WORKTREE_DIR"; then
  {
    echo "status=error"
    echo "message=Constructed path is invalid"
  } >> "$GITHUB_OUTPUT_FILE"
  exit 1
fi

if ! validate_path_safety "$WORKTREE_PARENT"; then
  {
    echo "status=error"
    echo "message=Parent path is invalid"
  } >> "$GITHUB_OUTPUT_FILE"
  exit 1
fi

# Output results
echo ""
echo "✓ Worktree directory validation passed"
echo "  Final path:  ${WORKTREE_DIR}"
echo "  Parent path: ${WORKTREE_PARENT}"

{
  echo "status=success"
  echo "message=Worktree directory validated"
  echo "worktree-dir=${WORKTREE_DIR}"
  echo "worktree-parent=${WORKTREE_PARENT}"
} >> "$GITHUB_OUTPUT_FILE"

exit 0
