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
#      REVISION: 5
#===============================================================================

LC_ALL=C
LANG=C
set -e
set -o nounset
set -o pipefail
set -u

DIR="/home/cbodden/git/mine/nd-to-slack"

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
    if [[ -e ${DIR}/config/${NAME::-3}.config ]]
    then
        source ${DIR}/config/${NAME::-3}.config
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

function _Note()
{
    case ${EMOJI} in
        "1")
            readonly _ICON=""
            ;;
        "2")
            readonly _ICON=":musical_note:"
            ;;
        "3" | *)
            declare -r NOTE=(\
                "musical_note" "musical_score" "musical_keyboard" "headphones" \
                "notes" "saxophone" "guitar" "trumpet" "violin" "microphone" \
                "drum_with_drumsticks" "banjo" "headphones")

            local _SIZE=${#NOTE[@]}
            local _INDEX=$(($RANDOM % ${_SIZE}))
            readonly _ICON=":${NOTE[${_INDEX}]}:"
            ;;
    esac
}

function _Post()
{
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
        local _PARENT=$(${JQ} \
            '."subsonic-response".nowPlaying.entry'[${_CNT}]'.parent' \
            ${TMPFILE})

        _CNT=$(( ${_CNT} + 1 ))

        if [ ! -f "/tmp/${NAME::-3}/${_USER}.out" ]
        then
            if [ ! -d "/tmp/${NAME::-3}" ]
            then
                mkdir /tmp/${NAME::-3}
            fi

            echo ${_USER} > /tmp/${NAME::-3}/${_USER}.out
            echo ${_ARTIST} >> /tmp/${NAME::-3}/${_USER}.out
            echo ${_TITLE} >> /tmp/${NAME::-3}/${_USER}.out
            echo ${_ALBUM} >> /tmp/${NAME::-3}/${_USER}.out
        else
            if grep -q -x "${_TITLE}" "/tmp/${NAME::-3}/${_USER}.out"
            then
                exit 0
            else
                echo ${_USER} > /tmp/${NAME::-3}/${_USER}.out
                echo ${_ARTIST} >> /tmp/${NAME::-3}/${_USER}.out
                echo ${_TITLE} >> /tmp/${NAME::-3}/${_USER}.out
                echo ${_ALBUM} >> /tmp/${NAME::-3}/${_USER}.out
            fi
        fi

        local _TXT1="${_ICON} ${_USER//\"} is listening to _${_TITLE//\"}_"
        local _TXT2=" by _${_ARTIST//\"}_ off of _${_ALBUM//\"}_."
        local _TXT3="\n:link: ${SERVER//\"}/app/#/album/${_PARENT//\"}/show"

        case ${LINK} in
            "1")
                local _LNK="${_TXT1}${_TXT2}${_TXT3}"
                ;;
            "2" | *)
                local _LNK="${_TXT1}${_TXT2}"
                ;;
        esac

        ${CURL} \
            -X POST \
            -H 'Content-type: application/json' \
            --data "{\"text\":\"${_LNK}\"}" \
            "${URL_API}/${URL_HOOK}"

    done
}

main
_NdOut
_Length
if [ "${_LEN}" -gt "0" ]
then
    _Note
    _Post
else
    exit 0
fi
