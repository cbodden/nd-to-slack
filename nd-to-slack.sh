#!/usr/bin/env bash
#===============================================================================
#
#          FILE: nd_to_slack.sh
#         USAGE: ./nd_to_slack.sh
#
#   DESCRIPTION: posts usr and listening info from the navidrome SERVER
#                to slack
#       OPTIONS: none
#  REQUIREMENTS: curl, jq, slack, and navidrome
#          BUGS: none so far
#         NOTES: use wisely
#        AUTHOR: Cesar Bodden (), cesar@poa.nyc
#  ORGANIZATION: pissedoffadmins.com
#       CREATED: 16-AUG-24
#      REVISION: 2
#===============================================================================

LC_ALL=C
LANG=C
set -e
set -o nounset
set -o pipefail
set -u

function main()
{
    readonly NAME=$(basename $0)
    TMPFILE=$(mktemp /tmp/${NAME::-3}-XXXX)
    trap "rm -f ${TMPFILE}" EXIT

    local _DEPS="curl jq"
    for ITER in ${_DEPS}
    do
        if [ -z "$(which ${ITER} 2>/dev/null)" ]
        then
            printf "%s\n" \
                ". . .${ITER} not found. . ."
            exit 1
        else
            readonly ${ITER^^}="$(which ${ITER})"
        fi
    done

    ## check and source config file
    if [[ -e config/${NAME::-3}.config ]]
    then
        source config/${NAME::-3}.config
    else
        printf "%s\n" \
            ". . .Config file not found. . ."
        exit 1
    fi
}

function _NdOut()
{
    local _S1="${SERVER}/rest/getNowPlaying"
    local _S2="?u=${USER}&t=${TOKEN}&s=${SALT}"
    local _S3="&v=1.16.1&c=${NAME}&f=json"

    ${CURL} \
        --connect-timeout 5 \
        --silent \
        "${_S1}${_S2}${_S3}" \
        >> ${TMPFILE}
}

function _Length()
{
    local _RAW_LEN=$(\
        ${JQ} \
            '."subsonic-response".nowPlaying.entry | length' \
            ${TMPFILE})

    let "_LEN=${_RAW_LEN}"
}

function _Post()
{
    declare -r NOTE=(\
        "musical_note" "musical_score" "musical_keyboard" "headphones" \
        "notes" "saxophone" "guitar" "trumpet" "violin" "banjo" "microphone" \
        "drum_with_drumsticks" )

    local _SIZE=${#NOTE[@]}

    local _CNT="0"
    while [ "${_CNT}" -lt "${_LEN}" ]
    do
        local _USER=$(${JQ} \
            '."subsonic-response".nowPlaying.entry'[${_CNT}]'.username' \
            ${TMPFILE})
        local _ARTIST=$(${JQ} \
            '."subsonic-response".nowPlaying.entry'[${_CNT}]'.artist' \
            ${TMPFILE})
        local _TITLE=$(${JQ} \
            '."subsonic-response".nowPlaying.entry'[${_CNT}]'.title' \
            ${TMPFILE})
        local _ALBUM=$(${JQ} \
            '."subsonic-response".nowPlaying.entry'[${_CNT}]'.album' \
            ${TMPFILE})

        _CNT=$(( ${_CNT} + 1 ))

        local _INDEX=$(($RANDOM % ${_SIZE}))
        local _ICON=${NOTE[${_INDEX}]}
        local _TXT1=":${_ICON}: ${_USER//\"} is listening to ${_TITLE//\"}"
        local _TXT2=" by ${_ARTIST//\"} off of ${_ALBUM//\"}."

        curl \
            -X POST \
            -H 'Content-type: application/json' \
            --data "{\"text\":\"${_TXT1}${_TXT2}\" }" \
            "${URL_API}/${URL_HOOK}"
    done
}

main
_NdOut
_Length
if [ "${_LEN}" -gt "0" ]
then
    _Post
else
    exit 0
fi
