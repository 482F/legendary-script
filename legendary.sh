#!/usr/bin/env bash

set -ue -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink "${0}")")"; pwd)"

LEGENDARY_DIR="/mnt/e/Fgame/legendary"
LEGENDARY_PATH="${LEGENDARY_DIR}/legendary.exe"
WINDOWS_LEGENDARY_PATH="$(wslpath -m "${LEGENDARY_PATH}")"
ALIAS_TXT_PATH="${SCRIPT_DIR}/alias.txt"


cd "${LEGENDARY_DIR}"

args="${@}"

while read line; do
    appname="${line%%,*}"
    alias="${line#*,}"
    args="${args//${alias}/${appname}}"
done < "${ALIAS_TXT_PATH}"

result="$(cmd.exe /c "${WINDOWS_LEGENDARY_PATH}" ${args})"

if echo "${args}" | grep -E "list-games|list-installed|list-files|list-saves"; then
    while read line; do
        appname="${line%%,*}"
        alias="${line#*,}"
        if [ "${appname:-}" = "" ] || [ "${alias:-}" = "" ]; then
            break
        fi
        result="$(echo "${result}" | sed -e "s@${appname}@${alias}@g")"
    done < "${ALIAS_TXT_PATH}"
fi
result="$(echo "${result}" | sed -e "s@App name: \(.*\) | Ver@App name: \\\\e[31m\1\\\\e[39m | Ver@g")"
echo -e "${result}"
