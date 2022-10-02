# README

Demonstrate some examples of HLS packaging.  

TODO:

* variable bitrates
* encryption
* audio only with images

## Download realistic free audiobook content

Goto https://librivox.org/ and download some audio books  

```sh
mkdir -p ./sources/audiobooks/  
curl -vvv -L -o ./sources/audiobooks/christmas_short_works_2008_0812_64kb_mp3.zip http://www.archive.org/download/christmas_short_works_2008_0812/christmas_short_works_2008_0812_64kb_mp3.zip
unzip ./sources/audiobooks/christmas_short_works_2008_0812_64kb_mp3.zip -d ./sources/audiobooks/christmas_short_works_2008_0812_64kb_mp3
```

## 01 - Creating HLS streams

Demonstrate some examples of creating HLS streams.  
Steps [README.md](./01_create_hls_streams/README.md)  

## 02 - Create HLS from segments

Demonstrates building a hls from individual segments of wav files.  
Steps [README.md](./02_create_hls_from_segments/README.md)  

## 04 - Simple HLS player

Configure a HLS streamer and player  
Steps [README.md](./04_simple_hls_player/README.md)  

## 05 - stdin to HLS

Demonstrate sending audio data to `ffmpeg` over stdin.  
Steps [README.md](./05_stdin_to_hls/README.md)  

## Resources

* Setting up HLS live streaming server using NGINX + nginx-rtmp-module on Ubuntu [here](https://docs.peer5.com/guides/setting-up-hls-live-streaming-server-using-nginx/)
* An overview of how to get started using Video.js, from basic CDN usage to Browserify, along with examples. [here](https://videojs.com/getting-started)
* HLS.js is a JavaScript library that implements an HTTP Live Streaming client. It relies on HTML5 video and MediaSource Extensions for playback. [here](https://github.com/video-dev/hls.js)

* Bento4 MP4, DASH, HLS, CMAF SDK and Tools [here](https://www.bento4.com/)
* HTTP Live Streaming blog [here](https://hlsbook.net/blog/)
* Generating HLS Playlists with Bento4 [here](https://hlsbook.net/generating-hls-playlists-with-bento4/)
* Streaming HLS with Nginx’s RTMP Module [here](https://hlsbook.net/hls-nginx-rtmp-module/)