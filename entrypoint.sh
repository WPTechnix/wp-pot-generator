#!/bin/bash

set -euo pipefail

WORKING_DIRECTORY="${1:-.}"
SOURCE="${2:-.}"
OUTPUT_FILE="${3:-./languages/<slug>.pot}"
SLUG="${4:-}"
DOMAIN="${5:-}"
PACKAGE_NAME="${6:-}"
HEADERS="${7:-}"
EXCLUDE="${8:-}"
INCLUDE="${9:-}"
IGNORE_DOMAIN="${10:-false}"

# Resolve working directory
if [ -n "${GITHUB_WORKSPACE:-}" ]; then
  BASE_DIR="$GITHUB_WORKSPACE"
else
  BASE_DIR="$PWD"
fi

case "$WORKING_DIRECTORY" in
  /*) FULL_WORKING_DIR="$WORKING_DIRECTORY" ;;
  *)  FULL_WORKING_DIR="$BASE_DIR/$WORKING_DIRECTORY" ;;
esac

if [ ! -d "$FULL_WORKING_DIR" ]; then
  echo "::error title=Directory Not Found::Working directory does not exist: $FULL_WORKING_DIR"
  exit 1
fi

cd "$FULL_WORKING_DIR"
FULL_WORKING_PWD="$PWD"

# Resolve source path
case "$SOURCE" in
  /*) FULL_SOURCE="$SOURCE" ;;
  *)  FULL_SOURCE="$PWD/$SOURCE" ;;
esac

if [ ! -d "$FULL_SOURCE" ]; then
  echo "::error title=Source Not Found::Source directory does not exist: $FULL_SOURCE"
  exit 1
fi

FULL_SOURCE="$(cd "$FULL_SOURCE" && pwd)"

# Auto-detect slug from directory basename if not provided
if [ -z "$SLUG" ]; then
  SLUG=$(basename "$FULL_SOURCE")
  echo "::notice title=Slug Detection::No slug provided. Using directory basename: $SLUG"
fi

# Replace <slug> placeholder in output-file
OUTPUT_FILE="${OUTPUT_FILE//<slug>/$SLUG}"

# Resolve output path (relative to working directory, not source)
case "$OUTPUT_FILE" in
  /*) FULL_OUTPUT="$OUTPUT_FILE" ;;
  *)  FULL_OUTPUT="$FULL_WORKING_PWD/$OUTPUT_FILE" ;;
esac

# Create output directory if it does not exist
OUTPUT_DIR=$(dirname "$FULL_OUTPUT")
if [ ! -d "$OUTPUT_DIR" ]; then
  mkdir -p "$OUTPUT_DIR"
fi

# Build optional WP-CLI flags
WP_ARGS=()

if [ -n "$DOMAIN" ]; then
  WP_ARGS+=(--domain="$DOMAIN")
fi

if [ "$IGNORE_DOMAIN" = "true" ]; then
  WP_ARGS+=(--ignore-domain)
fi

if [ -n "$PACKAGE_NAME" ]; then
  WP_ARGS+=(--package-name="$PACKAGE_NAME")
fi

if [ -n "$HEADERS" ]; then
  WP_ARGS+=(--headers="$HEADERS")
fi

if [ -n "$EXCLUDE" ]; then
  WP_ARGS+=(--exclude="$EXCLUDE")
fi

if [ -n "$INCLUDE" ]; then
  WP_ARGS+=(--include="$INCLUDE")
fi

# Run wp i18n make-pot
echo "::group::wp i18n make-pot"
set +e
wp i18n make-pot \
  "$FULL_SOURCE" \
  "$FULL_OUTPUT" \
  --slug="$SLUG" \
  "${WP_ARGS[@]}" \
  --allow-root
EXIT_CODE=$?
set -e
echo "::endgroup::"

if [ $EXIT_CODE -ne 0 ]; then
  echo "::error title=WP-CLI Failed::wp i18n make-pot exited with code $EXIT_CODE"
  exit $EXIT_CODE
fi

# Validate output and count strings
if [ ! -f "$FULL_OUTPUT" ]; then
  echo "::warning title=Output File Not Found::wp i18n make-pot did not create the expected output file: $FULL_OUTPUT"
  STRING_COUNT=0
  ABS_OUTPUT=""
  ABS_DIR=""
else
  STRING_COUNT=$(grep -c '^msgid ' "$FULL_OUTPUT" 2>/dev/null || echo 0)
  STRING_COUNT=$((STRING_COUNT > 0 ? STRING_COUNT - 1 : 0))
  ABS_OUTPUT=$(cd "$(dirname "$FULL_OUTPUT")" && pwd -P)/$(basename "$FULL_OUTPUT")
  ABS_DIR=$(dirname "$ABS_OUTPUT")
  echo "Generated POT file with ${STRING_COUNT} translatable string(s) at ${ABS_OUTPUT}"
fi

# Set outputs
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  {
    echo "output-path=$ABS_OUTPUT"
    echo "output-directory=$ABS_DIR"
    echo "string-count=$STRING_COUNT"
    echo "slug=$SLUG"
  } >> "$GITHUB_OUTPUT"
fi
