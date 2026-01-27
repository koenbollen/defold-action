#!/bin/bash
set -euo pipefail

readonly defold_channel="${DEFOLD_CHANNEL:-stable}"
readonly defold_version="${DEFOLD_VERSION:-latest}"
readonly target_platform="${TARGET_PLATFORM:?"missing TARGET_PLATFORM"}"


# Determine Defold version:
if [ "$defold_version" == "latest" ]; then
  manifest="$(curl -sSfL "https://d.defold.com/${defold_channel}/info.json")"
  version="$(echo "$manifest" | jq -r .version)"
  sha1="$(echo "$manifest" | jq -r .sha1)"
  url="https://d.defold.com/archive/${sha1}/bob/bob.jar"
else
  version="$defold_version"
  url="https://github.com/defold/defold/releases/download/${defold_version}/bob.jar"
fi

# Download bob.jar:
mkdir -p "$GITHUB_WORKSPACE/.defold-cache/local"
bobjar="$GITHUB_WORKSPACE/.defold-cache/bob-${version}.jar"
if [[ -f "$bobjar" ]]; then
  echo "Using cached bob.jar version ${version}"
else
  echo "Downloading Defold's bob.jar version ${version}..."
  curl -sSfL "$url" -o "$bobjar"
fi
java -jar "$bobjar" --version
echo "cache: $GITHUB_WORKSPACE/.defold-cache"
ls -lph "$GITHUB_WORKSPACE/.defold-cache"

(
  cd "$GITHUB_WORKSPACE"

  JVM_OPTS=("-Xmx4G")
  EXTRA_OPTS=("--resource-cache-local=$GITHUB_WORKSPACE/.defold-cache/local")

  echo "Resolving dependencies..."
  java -jar "$bobjar" "${EXTRA_OPTS[@]}" resolve
  if [[ -n "${DEFOLD_BOB_CLEAN:-}" ]]; then
    echo "Cleaning..."
    java -jar "$bobjar" "${EXTRA_OPTS[@]}" clean
  fi

  if [[ -n "${VARIANT:-}" ]]; then
    echo "Using build variant: ${VARIANT}"
    EXTRA_OPTS+=("--variant" "${VARIANT}")
  fi

  if [[ -n "${EXTRA_CONFIG:-}" ]]; then
    echo "Writing extra-config.ini..."
    echo "$EXTRA_CONFIG" > extra-config.ini
    echo -n "DEBUG extra-config.ini: "
    base64 extra-config.ini
    EXTRA_OPTS+=("--settings" "extra-config.ini")
  fi

  if [[ "${LIVEUPDATE:-false}" == "true" ]]; then
    echo "Enabling live update support..."
    EXTRA_OPTS+=("--liveupdate" "yes")
  fi

  free -m
  export JVM_HEAP_SIZE=4G
  echo "Heap Size: ${JVM_HEAP_SIZE}"

  builddir=""
  case "$target_platform" in
    "win32" | "windows")
      echo "Building for $target_platform..."
      if ! java "${JVM_OPTS[@]}" -jar "$bobjar" "${EXTRA_OPTS[@]}" --platform "x86_64-win32" --architectures "x86_64-win32" --archive distclean build bundle; then
        echo "Failed to build for $target_platform"
        logfile="$GITHUB_WORKSPACE/build/x86_64-win32/log.txt"
        echo "Debug logs: ${logfile}"
        cat "$logfile"
        exit 1
      fi

      builddir="$(dirname build/default/*/*.exe)" # this is the only way to find the build dir (it includes the project name which we dont know)
      ;;
    "linux")
      echo "Building for $target_platform..."
      if ! java "${JVM_OPTS[@]}" -jar "$bobjar" "${EXTRA_OPTS[@]}" --platform "x86_64-linux" --architectures "x86_64-linux" --archive distclean build bundle; then
        echo "Failed to build for $target_platform"
        logfile="$GITHUB_WORKSPACE/build/x86_64-linux/log.txt"
        echo "Debug logs: ${logfile}"
        cat "$logfile"
        exit 1
      fi

      builddir="$(dirname build/default/*/*.x86_64)" # this is the only way to find the build dir (it includes the project name which we dont know)
      ;;
    "web")
      echo "Building for $target_platform..."
      mkdir -p /tmp/bob
      export DM_BOB_ROOTFOLDER=/tmp/bob
      if ! java "${JVM_OPTS[@]}" -jar "$bobjar" "${EXTRA_OPTS[@]}" --platform "wasm-web" --architectures "wasm-web" --archive distclean build bundle; then
        echo "Failed to build for $target_platform"
        echo "Tint executable:" /tmp/*/x86_64-linux/tint
        ls -l /tmp/bob/x86_64-linux/tint || true
        file /tmp/bob/x86_64-linux/tint || true
        ldd  /tmp/bob/x86_64-linux/tint || true
        chmod +x /tmp/bob/x86_64-linux/tint
        /tmp/bob/x86_64-linux/tint --help
        logfile="$GITHUB_WORKSPACE/build/wasm-web/log.txt"
        echo "Debug logs: ${logfile}"
        cat "$logfile"
        exit 1
      fi

      builddir="$(dirname build/default/*/index.html)" # this is the only way to find the build dir (it includes the project name which we dont know)
      ;;
    *)
      echo "Unknown platform: $target_platform"
      exit 1
      ;;
  esac

  if [[ -d "$builddir" && -n "${GITHUB_OUTPUT:-}" ]]; then
    echo "build-path=$builddir" >> "$GITHUB_OUTPUT"
  fi
)
echo "fin"
