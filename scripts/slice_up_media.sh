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
    -i=file, --input=file           source file
    -o=filepath, --output=filepath  folder to store chunks in
    -s=seconds, --seconds=seconds   number of seconds per chunk
    -c=type, --codec=type           [wav,aac]

Examples:
    $SCRIPT_NAME --help 
    $SCRIPT_NAME --input=./output/testtone.wav --output=./output/testtonechunks -s=1
    
EOF
}

INPUT=
OUTPATH=
DURATION_SECONDS=1
CODEC=wav
TOTAL_SEGMENTS=1

# loop over all switches
for i in "$@"
do
case $i in
    -h|--help)
        help
        exit 0
    ;; 
    -i=*|--input=*)
        INPUT="${i#*=}"
        shift # past argument=value
    ;;     
    -o=*|--output=*)
        OUTPATH="${i#*=}"
        shift # past argument=value
    ;;  
    -s=*|--seconds=*)
        DURATION_SECONDS="${i#*=}"
        shift # past argument=value
    ;;       
    --segments=*)
        TOTAL_SEGMENTS="${i#*=}"
        shift # past argument=value
    ;;       
    -c=*|--codec=*)
        CODEC="${i#*=}"
        shift # past argument=value
    ;;       
esac
done    

if [[ "$INPUT"  == "" ]]; then
    >&2 echo ""
    >&2 echo "ERROR: input is not specified"
    >&2 echo ""
    exit 1
fi

if [[ ! -f $INPUT ]]; then
    >&2 echo ""
    >&2 echo "ERROR: '$INPUT' is not a file"
    >&2 echo ""
    exit 1
fi

if [[ "$OUTPATH" == "" ]]; then
    >&2 echo ""
    >&2 echo "ERROR: output is not specified"
    >&2 echo ""
    exit 1
fi

## Slice up

mkdir -p $OUTPATH

# use soxi to determine duration to calculate number of segments required. 
if [[ "$TOTAL_SEGMENTS" == "1" ]]; then
    TOTAL_SEGMENTS=$(soxi -D "$INPUT" | awk '{print int($1 + 1)}')
fi
echo "Splitting '$INPUT' into $TOTAL_SEGMENTS $DURATION_SECONDS sec chunks" 
count=0
for index in $(gseq -s " " -f %010g 0 $DURATION_SECONDS $(( TOTAL_SEGMENTS - 1 )));
do  
    fileid=$(gseq -s " " -f %010g $count $count)
    echo "write ${OUTPATH}/$fileid.wav $index duration $DURATION_SECONDS"
    sox "$INPUT" "${OUTPATH}/$fileid.wav" trim $index $DURATION_SECONDS
    count=$((count+1))
done
