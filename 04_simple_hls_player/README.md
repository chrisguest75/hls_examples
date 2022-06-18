# Streaming

Configure a HLS streamer and player

## Build player

```sh
# build the container
docker build -t streaming .

# run the player
docker run -it -d -p 8080:80 -v $(pwd)/streams:/usr/share/nginx/html/videos --name streaming streaming

open http://0.0.0.0:8080
xdg-open http://0.0.0.0:8080

docker stop streaming

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