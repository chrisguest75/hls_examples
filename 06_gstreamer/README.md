# README

Demonstrate using gstreamer to fragment an audio file into HLS.  

## Preequisites

Info on `gstreamer` installation can be found [here](https://github.com/chrisguest75/shell_examples/blob/master/58_gstreamer/README.md)  

Requires `gst-plugins-bad` for AAC.  

## Example

### RSS Feed download

```sh
mkdir -p ./out
# get rss feed
curl -s -o ./out/lnlrss.xml https://latenightlinux.com/feed/mp3
# get first url
FEED_URL=$(xmllint --xpath 'string(//rss/channel/item[1]/enclosure/@url)' --format --pretty 2 ./out/lnlrss.xml)
# get the file
PODCASTFILE=$(basename $FEED_URL)
curl -s -L -o ./out/${PODCASTFILE} $FEED_URL

../scripts/convert_to_codec.sh --input=./out/LNL208.mp3 --output=./out/LNL208.wav --codec=wav
../scripts/convert_to_codec.sh --input=./out/LNL208.wav --output=./out/LNL208.mp4 --codec=aac
```

```sh
mkdir -p ./out/hls

# requires `gst-plugins-bad` for AAC.  
#filesrc location=./out/LNL208.mp4
gst-launch-1.0 audiotestsrc is-live=true ! aacparse ! audio/mpeg ! queue ! mpegtsmux ! hlssink playlist-length=5 max-files=10 target-duration=5 playlist-root="http://localhost/hls/" playlist-location="./out/hls/stream0.m3u8" location="./out/hls/fragment%05d.ts"
```

## Resources

https://stackoverflow.com/questions/40978327/i-want-to-create-a-hls-http-live-streaming-stream-using-gstreamer-but-audio-on