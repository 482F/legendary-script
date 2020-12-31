#!/usr/bin/env bash

set -ue -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink "${0}")")"; pwd)"

LEGENDARY_DIR="/mnt/e/Fgame/legendary"
LEGENDARY_EXE_NAME="legendary.exe"
LEGENDARY_PATH="${LEGENDARY_DIR}/${LEGENDARY_EXE_NAME}"
WINDOWS_LEGENDARY_DIR="$(wslpath -m "${LEGENDARY_DIR}")"
WINDOWS_LEGENDARY_PATH="$(wslpath -m "${LEGENDARY_PATH}")"
ALIAS_TXT_PATH="${SCRIPT_DIR}/alias.txt"


cd "${LEGENDARY_DIR}"

args="${@}"

while read line; do
    appname="${line%%,*}"
    alias="${line#*,}"
    args="${args//${alias}/${appname}}"
done < "${ALIAS_TXT_PATH}"

main(){
    local result="$(cmd.exe /c "${WINDOWS_LEGENDARY_PATH}" ${args})"

    if echo "${args}" | grep -E "list-games|list-installed|list-files|list-saves"; then
        while read line; do
            appname="${line%%,*}"
            alias="${line#*,}"
            if [ "${appname:-}" = "" ] || [ "${alias:-}" = "" ]; then
                break
            fi
            result="$(echo "${result}" | sed -e "s@${appname}@${alias}@g")"
            result="$(echo "${result}" | sed -e "s@App name: \(${alias}\) | Ver@App name: \\\\e[31m\1\\\\e[39m | Ver@g")"
        done < "${ALIAS_TXT_PATH}"
    fi
    echo "${result}"
}

reauth(){
    cmd.exe /c "${WINDOWS_LEGENDARY_DIR}/auth.bat"
}

case "${1}" in
reauth)
    result="$(reauth)"
    ;;
*)
    result="$(main "${args}")"
esac

echo -e "${result}"
