# README

Demonstrate how to monitor a folder for changes.  


https://github.com/chrisguest75/shell_examples/blob/master/47_ffmpeg/RECORDING.md

TODO:

* Start a recording
* Monitor folder for new files.
* Add to the HLS stream

## Prereqs

```sh
apt install inotify-tools
```

## Example

```sh
mkdir -p ./out
./notify.sh "./out"

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