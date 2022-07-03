#!/usr/bin/env bash

rm -rf ./output/partialhls
mkdir -p ./output/partialhls
# create first segment
ffmpeg -y -hide_banner -i "./output/chunked/${WAVFILE_NOEXT}.0000.wav" -c:a aac -b:a 128k -muxdelay 0 -f segment -segment_time 100 -segment_list "./output/partialhls/playlist.m3u8" -segment_format mpegts "./output/partialhls/file%d.ts"

## NOTE modify pts
ffprobe -v error -show_format -show_streams -print_format json "./output/chunked/${WAVFILE_NOEXT}.0010.wav" | jq '.streams[].codec_time_base'

for CHUNK in $(seq -s " " -f %04g 10 10 $DURATION_SECONDS); 
do
    # sum current duration for new audio pts
    CURRENT_DURATION=$(cat ./output/partialhls/playlist.m3u8 | grep EXTINF | awk -F':' '{gsub(/,/, "", $2);print $2}' | awk '{OFMT = "%9.6f";s+=$1} END {print s}')
    echo "CURRENT_DURATION=$CURRENT_DURATION"
    # add segment
    ffmpeg -y -hide_banner -i "./output/chunked/${WAVFILE_NOEXT}.${CHUNK}.wav" -c:a aac -b:a 128k -muxdelay 0 -filter_complex "[0:a]asetpts=PTS+$(( 22050.0 * $CURRENT_DURATION ))" -hls_playlist_type event -hls_segment_filename "./output/partialhls/file%d.ts" -hls_time 100 -hls_flags append_list "./output/partialhls/playlist.m3u8"
    # remove discontinuity
    cat ./output/partialhls/playlist.m3u8 | grep -v "#EXT-X-DISCONTINUITY" > ./output/partialhls/fixed_playlist.m3u8
done > ./output.txt

# inspect a segment 
ffprobe -v error -show_format -show_streams -print_format json ./output/partialhls/file2.ts | jq .

# frame time codes
ffprobe -v error -print_format json -show_frames ./output/partialhls/file0.ts | jq '.frames[].pkt_pts_time'

# print out start times and durations
while IFS=, read -r _filename
do
    ffprobe -v error -show_format -show_streams -print_format json ./output/partialhls/$_filename | jq --arg filename "${_filename}" -c '{ file: $filename, start_time:.format.start_time, duration:.format.duration, pts: .streams[0].start_pts, time_base: .streams[0].time_base, codec_time_base: .streams[0].codec_time_base}'
done < <(ls ./output/partialhls)