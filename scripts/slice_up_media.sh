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
TOTAL_SEGMENTS=10

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

# use segmentor (doesn't seem to give accurate durations)
# ffmpeg -hide_banner -y -i "$INPUT" -f segment -break_non_keyframes 1 -segment_time $DURATION_SECONDS ${OUTPATH}/file_%03d.wav

# gstreamer seems to undercut the files
# 10000000000
# 1000000000 
# gst-launch-1.0 filesrc location="$INPUT" ! decodebin ! audioconvert ! splitmuxsink location=${OUTPATH}/file_%03d.wav muxer=wavenc max-size-time=1000000000

# using sox gives an accurate cut
# gseq and gdate or seq and date
for index in $(gseq -s " " -f %04g 0 $DURATION_SECONDS $(( TOTAL_SEGMENTS - 1 ))); 
do  
    echo "write ${OUTPATH}/file$index.wav $index duration $DURATION_SECONDS"
    sox "$INPUT" "${OUTPATH}/file$index.wav" trim $index $DURATION_SECONDS
done



# TOTAL_SEGMENTS=10
# # gseq and gdate or seq and date
# for index in $(gseq -s " " -f %04g 0 $DURATION_SECONDS $TOTAL_SEGMENTS); 
# do
#     _starttime=$(gdate -d@$index -u +%H:%M:%S)
#     echo "-ss $_starttime -t 00:00:$DURATION_SECONDS"
#     ffmpeg -hide_banner -y -i "$INPUT" -ss $_starttime -t 00:00:$DURATION_SECONDS -acodec copy ${OUTPATH}/file$index.wav < /dev/null
# done

# list chunks
#ll ./output/chunked

# inspect a segment 
#ffprobe -v error -show_format -show_streams -print_format json ./output/chunked/${WAVFILE_NOEXT}.0010.wav | jq .
