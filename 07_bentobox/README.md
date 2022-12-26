# README

Demonstrate using bento4 to fragment an audio file into HLS.  
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



mp42hls --segment-duration-threshold 0 --index-filename ./out/hls/main.m3u8 --segment-filename-template "./out/hls/segment-%d.ts" ./out/LNL208.mp4


fq .continuity_counter ./out/hls/segment-6.ts
```


## Resources

* Generating HLS Playlists with Bento4 [here](https://hlsbook.net/generating-hls-playlists-with-bento4/)  


https://www.bento4.com/documentation/mp4hls/

https://www.bento4.com/documentation/mp42ts/


