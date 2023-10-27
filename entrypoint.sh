#!/bin/bash
set -euo pipefail

readonly defold_channel="${DEFOLD_CHANNEL:-stable}"

manifest="$(curl -sL "https://d.defold.com/${defold_channel}/info.json")"
version="$(echo "$manifest" | jq -r .version)"
sha1="$(echo "$manifest" | jq -r .sha1)"

echo "Downloading Defold's bob.jar version ${version}..."
curl -sL "https://d.defold.com/archive/${sha1}/bob/bob.jar" -o /bob.jar

(
  cd "$GITHUB_WORKSPACE"
  java -jar /bob.jar --archive --platform wasm-web --architectures wasm-web resolve distclean build bundle
)
