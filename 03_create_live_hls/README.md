# README

Demonstrate how to simulate a remote process sending audio and building a HLS on the server side.  


https://github.com/chrisguest75/shell_examples/blob/master/47_ffmpeg/RECORDING.md

TODO:

* Start a recording
* Monitor folder for new files.
* Add to the HLS stream

## Start

```sh
# trim
ffmpeg -hide_banner -i "../sources/audiobooks/christmas_short_works_2008_0812_64kb_mp3/english_achristmastree_dickens_rg_64kb.mp3" -t 00:00:30 ../sources/audiobooks/christmas_short_works_2008_0812_64kb_mp3/english_achristmastree_dickens_rg_64kb_30s.mp3

# use segment 
OUT_FOLDER=./out/segment
rm -rf "${OUT_FOLDER}"
mkdir -p "${OUT_FOLDER}"
ffmpeg -hide_banner -y -i "../sources/audiobooks/christmas_short_works_2008_0812_64kb_mp3/english_achristmastree_dickens_rg_64kb_30s.mp3" -vn -c:a aac -b:a 128k -ar 16000 -channels 1 -muxdelay 0 -f segment -segment_time 6 -segment_list "${OUT_FOLDER}/playlist.m3u8" -segment_format mpegts "${OUT_FOLDER}/file%d.ts"


# use hls
OUT_FOLDER=./out/hls
rm -rf "${OUT_FOLDER}"
mkdir -p "${OUT_FOLDER}"
ffmpeg -hide_banner -y -i "../sources/audiobooks/christmas_short_works_2008_0812_64kb_mp3/english_achristmastree_dickens_rg_64kb_30s.mp3" -vn -c:a aac -b:a 128k -ar 16000 -channels 1 -muxdelay 0 -f hls -hls_segment_type mpegts -hls_time 6 -hls_playlist_type event -hls_flags append_list+independent_segments -hls_segment_filename "${OUT_FOLDER}/file%d.ts" "${OUT_FOLDER}/playlist.m3u8" 


```






## Prereqs

```sh
apt install inotify-tools
```

## Example

```sh
# shell 1
mkdir -p ./out
./notify.sh "./out"

# shell 2
ffmpeg -hide_banner -f pulse -i alsa_input.pci-0000_00_1b.0.analog-stereo -ac 1 -ar 22050 -segment_time 00:00:10 -f segment ./out/recording%03d.wav

```

## Docker

Try the notify behaviour inside a container.  

NOTE: This should be tried on MacOS and Linux to check behaviour  

### Build

```sh
# build the image
docker build --no-cache --progress=plain -t monitor . 
```

### Run

```sh
# run a command 
docker run --rm -it -v$(realpath ./test):/share monitor
```

## Resources

* script-to-monitor-folder-for-new-files [here](https://unix.stackexchange.com/questions/24952/script-to-monitor-folder-for-new-files)

https://stackoverflow.com/questions/8699293/how-to-monitor-a-complete-directory-tree-for-changes-in-linux/64107015#64107015

https://unix.stackexchange.com/questions/323901/how-to-use-inotifywait-to-watch-a-directory-for-creation-of-files-of-a-specific