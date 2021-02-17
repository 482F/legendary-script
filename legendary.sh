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
    if echo "${args}" | grep -E "list-games|list-installed|list-files|list-saves"; then
        local result="$(cmd.exe /c "${WINDOWS_LEGENDARY_PATH}" ${args})"
        max_length=0
        while read line; do
            if [ "${max_length}" -lt "${#line}" ]; then
                max_length="${#line}"
            fi
        done < <(echo "${result}" | sed -ne "s@^ \*@@p" | sed -e "s@(App name:.*@@g")
        aligned_result=""
        while read line; do
            if echo "${line}" | grep -qP "^\*"; then
                app_name="$(echo "${line}" | sed -e "s@(App name:.*@@g")"
                if [ "${app_name}" = "" ]; then
                    app_name="$(echo "${line}" | grep -oP "^\* .*")"
                fi
                length="${#app_name}"
                filling="$(printf %$((max_length-length+5))s)"
                leftover="$(echo "${line}" | grep -oP "\(App name:.*")"
                aligned_result="${aligned_result}\n ${app_name}${filling}${leftover}"
            elif echo "${line}" | grep -qP "^(\+|\-\>)"; then
                filling="$(printf %$((max_length+10))s)"
                aligned_result="${aligned_result}\n${filling}${line}"
            else
                aligned_result="${aligned_result}\n${line}"
            fi
        done < <(echo "${result}")
        result="${aligned_result}"
        while read line; do
            appname="${line%%,*}"
            alias="${line#*,}"
            if [ "${appname:-}" = "" ] || [ "${alias:-}" = "" ]; then
                break
            fi
            result="$(echo "${result}" | sed -e "s@${appname}@${alias}@g")"
            result="$(echo "${result}" | sed -e "s@App name: \(${alias}\) | Ver@App name: \\\\e[31m\1\\\\e[39m | Ver@g")"
        done < "${ALIAS_TXT_PATH}"
    else
        local result=""
        cmd.exe /c "${WINDOWS_LEGENDARY_PATH}" ${args}
    fi
    echo -e "${result}"
}

reauth(){
    cmd.exe /c "${WINDOWS_LEGENDARY_DIR}/auth.bat"
}

case "${1:-}" in
reauth)
    reauth
    ;;
*)
    main "${args}"
esac
