# Streaming

Demonstrate some examples of creating HLS streams.  

## Build HLS

```sh
# prepare file for HLS segmentation
ffmpeg -i ./output/bigbuckbunny/bigbuckbunny-x264-st-16bit_timecode.mp4 -c:v h264 -crf 22 -tune film -profile:v main -level:v 4.0 -minrate 5000k -maxrate 5000k -bufsize 5000k -r 24 -keyint_min 24 -g 48 -sc_threshold 0 -c:a aac -b:a 128k -ac 2 -ar 44100 -pix_fmt yuv420p -movflags +faststart ./output/bigbuckbunny/bigbuckbunny-x264-st-16bit_timecode-hlsready.mp4

# segment file
mkdir -p ./output/bigbuckbunny-hls  
pushd ./output/bigbuckbunny-hls  
mp42hls ../../output/bigbuckbunny/bigbuckbunny-x264-st-16bit_timecode-hlsready.mp4

# output dir does not work
#mp42hls --output-dir=./output/bigbuckbunny-hls/ --verbose --output-single-file ./output/bigbuckbunny/bigbuckbunny-x264-st-16bit_timecode-hlsready.mp4
```

## Resources

https://ffmpegfromzerotohero.com/blog/ffmpeg-tutorial-convert-and-stream-your-videos-with-hls-and-videojs/

https://docs.peer5.com/guides/setting-up-hls-live-streaming-server-using-nginx/

https://videojs.com/getting-started

https://github.com/video-dev/hls.js
https://www.bento4.com/

https://hlsbook.net/blog/
https://hlsbook.net/generating-hls-playlists-with-bento4/

https://hlsbook.net/hls-nginx-rtmp-module/