#!/usr/bin/env bash
set -euf -o pipefail

readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_PATH=${0}
# shellcheck disable=SC2034
readonly SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

function help() {
    cat <<- EOF
usage: $SCRIPT_NAME options

Convert an input audio file to wav or aac file.

OPTIONS:
    -h --help -?                    show this help
    -i=file, --input=path           source file
    -o=file, --output=file          converted
    -c=type, --codec=type           [wav,aac,pcm]

Examples:
    $SCRIPT_NAME --help 
    $SCRIPT_NAME --input=./output/./output/testtone.m4a --output=./output/testtone.wav --codec=wav

EOF
}

INPUT=
OUTFILE=
CODEC=wav

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
        OUTFILE="${i#*=}"
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

if [[ "$OUTFILE" == "" ]]; then
    >&2 echo ""
    >&2 echo "ERROR: output is not specified"
    >&2 echo ""
    exit 1
fi

ffprobe -v error -show_format -show_streams -print_format json ${INPUT} | jq --arg filename "${INPUT}" -c '{ file: $filename, start_time:.format.start_time, duration:.format.duration, pts: .streams[0].start_pts, time_base: .streams[0].time_base}'

case $CODEC in
    wav)
        # wav 
        ffmpeg -y -hide_banner -i ${INPUT} ${OUTFILE}
    ;; 
    aac)
        # aac
        ffmpeg -y -hide_banner -i ${INPUT} -strict very -flags low_delay -c:a:0 aac -profile:a aac_low -b:a 64k -filter_complex "[0]asettb=1/44100,apad=pad_len=0,asetnsamples=nb_out_samples=512:p=0" ${OUTFILE}
    ;;       
    pcm)
        # pcm
        ffmpeg -y -hide_banner -i ${INPUT} -f 'f32le' -acodec pcm_f32le -ar 16000 ${OUTFILE}
    ;;
esac

ffprobe -v error -show_format -show_streams -print_format json ${OUTFILE}
ffprobe -v error -show_format -show_streams -print_format json ${OUTFILE} | jq --arg filename "${OUTFILE}" -c '{ file: $filename, start_time:.format.start_time, duration:.format.duration, pts: .streams[0].start_pts, time_base: .streams[0].time_base, codec_long_name: .streams[0].codec_long_name}'
