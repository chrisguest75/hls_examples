#!/usr/bin/env bash
set -euf -o pipefail

readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_PATH=${0}
# shellcheck disable=SC2034
readonly SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

function help() {
    cat <<- EOF
usage: $SCRIPT_NAME options

Slice up media file into chunks

OPTIONS:
    -h --help -?                    show this help
    -o=filepath, --output=filepath  folder to store chunks in
    -s=seconds, --seconds=seconds   number of seconds per chunk
    -c=type, --codec=type           [wav,aac]

Examples:
    $SCRIPT_NAME --help 

EOF
}

INPUT=
OUTPATH=
SECONDS=10
CODEC=wav

for i in "$@"
do
case $i in
    -h|--help)
        help
        exit 0
    ;; 
    -o=*|--output=*)
        OUTPATH="${i#*=}"
        shift # past argument=value
    ;;  
    -s=*|--seconds=*)
        SECONDS="${i#*=}"
        shift # past argument=value
    ;;       
    -c=*|--codec=*)
        CODEC="${i#*=}"
        shift # past argument=value
    ;;       
esac
done    

if [[ "$OUTPATH" == "" ]]; then
    >&2 echo ""
    >&2 echo "ERROR: output is not specified"
    >&2 echo ""
    exit 1
fi

case $CODEC in
    wav)
        # wav 
        ffmpeg -hide_banner -y -filter_complex aevalsrc="sin(140*2*PI*t)" -t ${SECONDS} -ac 1 -ar 22050 ${OUTPATH}
    ;; 
    aac)
        # aac
        ffmpeg -hide_banner -y -filter_complex aevalsrc="sin(140*2*PI*t)" -t ${SECONDS} -acodec aac -ac 1 -ar 22050 -ab 320k ${OUTPATH}
    ;;       
esac

