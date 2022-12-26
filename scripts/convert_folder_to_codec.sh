#!/usr/bin/env bash
set -euf -o pipefail

readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_PATH=${0}
# shellcheck disable=SC2034
readonly SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

function help() {
    cat <<- EOF
usage: $SCRIPT_NAME options

Convert a directory full of media segments to another codec.  

NOTE: Do not go from AAC to PCM directly because of the decode buffer at end of output.  

OPTIONS:
    -h --help -?                    show this help
    -f=path, --folder=path          source folder
    -o=filepath, --output=filepath  concatenated output file
    -c=type, --codec=type           [wav,aac,pcm]   
    --checkinput                    Does not verify, but prints source probe data
    --checkoutput                   Does not verify, but prints output probe data
    --no-extension                  Ensure extension is removed after conversion

Examples:
    $SCRIPT_NAME --help 
    $SCRIPT_NAME --folder=./sources/18-07-android-wav-mono --output=./output/18-07-android-wav-mono-aac --codec=aac

EOF
}

ASSET_FOLDER=
OUTPATH=
CODEC=wav
CHECK_INPUT=false
CHECK_OUTPUT=false
NOEXTENSIONS=false

# loop over all switches
for i in "$@"
do
case $i in
    -h|--help)
        help
        exit 0
    ;; 
    -f=*|--folder=*)
        ASSET_FOLDER="${i#*=}"
        shift # past argument=value
    ;;     
    -o=*|--output=*)
        OUTPATH="${i#*=}"
        shift # past argument=value
    ;;  
    -c=*|--codec=*)
        CODEC="${i#*=}"
        shift # past argument=value
    ;;  
    --checkinput)
        CHECK_INPUT=true
    ;;   
    --checkoutput)
        CHECK_OUTPUT=true
    ;;
    --no-extension)
        NOEXTENSIONS=true
    ;;  
esac
done    

if [[ "$ASSET_FOLDER"  == "" ]]; then
    >&2 echo ""
    >&2 echo "ERROR: folder is not specified"
    >&2 echo ""
    exit 1
fi

if [[ ! -d $ASSET_FOLDER ]]; then
    >&2 echo ""
    >&2 echo "ERROR: '$ASSET_FOLDER' is not a directory"
    >&2 echo ""
    exit 1
fi

if [[ "$OUTPATH" == "" ]]; then
    >&2 echo ""
    >&2 echo "ERROR: output is not specified"
    >&2 echo ""
    exit 1
fi

if [[ -d ${OUTPATH} ]]; then
    >&2 echo ""
    >&2 echo "WARNING: '$OUTPATH' is being removed"
    >&2 echo ""    
fi

LSCOMMAND=ls
if [[ $(command -v gls) ]]; then 
    # mac requires 'brew install coreutils'
    LSCOMMAND=gls
fi 

if [[ $CHECK_INPUT == true ]]; then
    while IFS=, read -r _filename
    do
        #size=$(gstat --printf="%s"  ${ASSET_FOLDER}/${_filename})
        ffprobe -v error -show_format -show_streams -print_format json ${ASSET_FOLDER}/$_filename | jq --arg filename "${_filename}" -c '{ file: $filename, start_time:.format.start_time, duration:.format.duration, pts: .streams[0].start_pts, time_base: .streams[0].time_base}'
    done < <(${LSCOMMAND} -1v ${ASSET_FOLDER})
else 
    echo "Skipping check input on ${ASSET_FOLDER}"
fi

mkdir -p ${OUTPATH}

while IFS=, read -r _filename
do
    _outfile=$(basename $_filename)
    if [[ $NOEXTENSIONS == true ]]; then
        # remove existing extension
        _outfile="${_outfile%.*}"
    fi
    case $CODEC in
        wav)
            # wav
            EXTENSION=".wav"
            ffmpeg -nostdin -y -hide_banner -i "${ASSET_FOLDER}/${_filename}" "${OUTPATH}/${_outfile}${EXTENSION}"
            sox "${OUTPATH}/${_outfile}.wav" "${OUTPATH}/${_outfile}.trim.wav" trim 0 1
            rm "${OUTPATH}/${_outfile}.wav"            
        ;; 
        pcm)
            # pcm
            EXTENSION=".pcm"
            ffmpeg -nostdin -y -hide_banner -i "${ASSET_FOLDER}/${_filename}" -f f32le -acodec pcm_f32le -ar 16000 "${OUTPATH}/${_outfile}${EXTENSION}"                   
        ;;         
        aac)
            # aac
            EXTENSION=".m4a"
            ffmpeg -nostdin -y -hide_banner -i "${ASSET_FOLDER}/${_filename}" -strict very -flags low_delay -c:a:0 aac -profile:a aac_low -b:a 64k -filter_complex "[0]asettb=1/44100,apad=pad_len=0,asetnsamples=nb_out_samples=512:p=0" "${OUTPATH}/${_outfile}${EXTENSION}"
            # remove extension signifying codec
            if [[ $NOEXTENSIONS == true ]]; then
                mv "${OUTPATH}/${_outfile}${EXTENSION}" "${OUTPATH}/${_outfile}"
            fi            
        ;;       
    esac
done < <(${LSCOMMAND} -1v ${ASSET_FOLDER})        

if [[ $CHECK_OUTPUT == true ]]; then
    while IFS=, read -r _filename
    do
        #size=$(gstat --printf="%s"  ${ASSET_FOLDER}/${_filename})
        ffprobe -v error -show_format -show_streams -print_format json ${OUTPATH}/$_filename | jq --arg filename "${_filename}" -c '{ file: $filename, start_time:.format.start_time, duration:.format.duration, pts: .streams[0].start_pts, time_base: .streams[0].time_base}'
    done < <(${LSCOMMAND} -1v ${OUTPATH})
else 
    echo "Skipping check output on ${OUTPATH}"
fi
