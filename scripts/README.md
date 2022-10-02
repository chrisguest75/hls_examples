# Scripts

Converting between codecs and containers and seeing how it changes durations.

## Slicing up media

```bash
# slice an asset up into 1 second chunks
../scripts/slice_up_media.sh --input=./out/english_thelittlegraylamb_sullivan_csm_64kb.wav --output=./out/english_thelittlegraylamb_sullivan_csm_64kb_1sec -s=01 --segments=268
```

## Convert

Convert a file to another codec.  

```sh
# take wav and convert back to aac
./scripts/convert_to_codec.sh --input="${AUDIO_FILE}" --output=./out/pcmtest.pcm --codec=pcm

# convert a whole directory into another codec
../scripts/convert_folder_to_codec.sh --folder=./out/english_thelittlegraylamb_sullivan_csm_64kb_1sec --output=./out/english_thelittlegraylamb_sullivan_csm_64kb_1sec_pcm --codec=pcm
```

## Chunk and convert

Chunk up audio into 5 seconds wavs then convert to AAC.  

```sh
../scripts/slice_up_media.sh --input=./out/english_thelittlegraylamb_sullivan_csm_64kb.wav --output=./out/english_thelittlegraylamb_sullivan_csm_64kb_5sec -s=05 --segments=268

../scripts/convert_folder_to_codec.sh --folder=./out/english_thelittlegraylamb_sullivan_csm_64kb_5sec --output=./out/english_thelittlegraylamb_sullivan_csm_64kb_5sec_aac --codec=aac
```
