# README

Demonstrate sending audio data to `ffmpeg` over stdin to create a HLS.  

Using `pipe:` or `pipe:` we can pipe raw data into ffmpeg over stdin.  

## Sources

Using the audiobook content mentioned in [README.md](../README.md)  

Decode to lossless.  

```bash
mkdir -p ./out

export AUDIO_FILE=../sources/audiobooks/christmas_short_works_2008_0812_64kb_mp3/english_thelittlegraylamb_sullivan_csm_64kb.mp3
ls -la ${AUDIO_FILE} 
# convert to raw pcm file f32le 16k mono.
../scripts/convert_to_codec.sh --input="${AUDIO_FILE}" --output=./out/english_thelittlegraylamb_sullivan_csm_64kb.pcm --codec=pcm
# convert to wav
../scripts/convert_to_codec.sh --input="${AUDIO_FILE}" --output=./out/english_thelittlegraylamb_sullivan_csm_64kb.wav --codec=wav
```

```bash
# individual 5sec chunks
../scripts/slice_up_media.sh --input=./out/english_thelittlegraylamb_sullivan_csm_64kb.wav --output=./out/english_thelittlegraylamb_sullivan_csm_64kb_5sec -s=05 --segments=268
../scripts/convert_folder_to_codec.sh --folder=./out/english_thelittlegraylamb_sullivan_csm_64kb_5sec --output=./out/english_thelittlegraylamb_sullivan_csm_64kb_5sec_pcm --codec=pcm
```

## Process (single file input)

```bash
# terminal 1 & 2
export PIPENAME=audio.pipe
export OUT_FOLDER=./out/singlefilehls
export AUDIO_FILE=./out/english_thelittlegraylamb_sullivan_csm_64kb.pcm 

# terminal 1
mkfifo ${PIPENAME}
cat ${AUDIO_FILE} > ${PIPENAME}

# terminal 2
#rm -rf ${OUT_FOLDER}
mkdir -p ${OUT_FOLDER}
ffmpeg -hide_banner -y -f f32le -ar 16000 -channels 1 -i pipe:0 -c:a aac -b:a 128k -muxdelay 0 -f hls -hls_time 10 -hls_segment_type mpegts -hls_segment_filename "${OUT_FOLDER}/file%d.ts" "${OUT_FOLDER}/playlist.m3u8" < ${PIPENAME}

rm ${PIPENAME}
 
vlc "${OUT_FOLDER}/playlist.m3u8"
```

## Process (chunked file input)

Open 2 terminals  

```bash
# terminal 1 & 2
export OUT_FOLDER=./out/chunkedfilehls
export PIPENAME=audio.pipe

# terminal 1
mkfifo ${PIPENAME}
# file descriptors are unique to a process (this is what keeps the pipe open).
exec 7<>${PIPENAME}

# repeat this 10 times with new segments
export AUDIO_FILE_FOLDER=./out/english_thelittlegraylamb_sullivan_csm_64kb_5sec_pcm

# this or a loop below
cat ./out/english_thelittlegraylamb_sullivan_csm_64kb_5sec_pcm/0000000001.wav.pcm > ${PIPENAME}

while IFS='=' read -r AUDIO_FILE
do
    echo "Processing:${AUDIO_FILE}"
    cat ${AUDIO_FILE} > ${PIPENAME}
    sleep 5
done < <(find ${AUDIO_FILE_FOLDER} -maxdepth 1 -type f | sort)

# terminal 2
rm -rf ${OUT_FOLDER}
mkdir -p ${OUT_FOLDER}
ffmpeg -hide_banner -y -f f32le -ar 16000 -channels 1 -i pipe:0 -c:a aac -b:a 128k -muxdelay 0 -f hls -hls_time 10 -hls_segment_type mpegts -hls_segment_filename "${OUT_FOLDER}/file%d.ts" -hls_flags append_list "${OUT_FOLDER}/playlist.m3u8" < ${PIPENAME}

# terminal 3
# to terminate the playlist you can send sigterm...
ps -a 
kill -SIGTERM 73992 

# playback
vlc "${OUT_FOLDER}/playlist.m3u8"

# cleanup
exec 7>&-   
rm ${PIPENAME}
```

## Resources

* Pipe input in to ffmpeg stdin [here](https://stackoverflow.com/questions/45899585/pipe-input-in-to-ffmpeg-stdin)
* ffmpeg docs 3.20 pipe [here](https://ffmpeg.org/ffmpeg-protocols.html#pipe)  
* POSIX signals [here](https://dsa.cs.tsinghua.edu.cn/oj/static/unix_signal.html)  
