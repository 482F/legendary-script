#!/usr/bin/env bash

set -ue -o pipefail

LEGENDARY_PATH="/mnt/e/Fgame/legendary/legendary.exe"
WINDOWS_LEGENDARY_PATH="$(wslpath -m "/mnt/e/Fgame/legendary/legendary.exe")"


cd "$(dirname ${LEGENDARY_PATH})"

cmd.exe /c "${WINDOWS_LEGENDARY_PATH}" "${@}"
