# White noise and random bitmap video generator

## Description

It's a random white noise audio/video generator based on ffmpeg, it supports HLS output, which can be play via ubiquitous softwares like Safari browser or VLC.

We demonstrated how to generate random audio/video via ffmpeg, how do produce muxed multimedia data streams and how to publish them via a web server like nginx.

## Usage

1. At first deploy, you have to build the image:

```
docker build -t whitenoise-generator:0.1 .
```

where the image name shall be coincide with what the `whitenoiseGeneratorImageName` field in `start.sh` script refers.

2. Launch web server and the ffmpeg container:

```
./start.sh
```

now we are ready to go.

## Screenshot

![screenshot](https://videos.idx.best/videos/demonstrations-24-03-30.mp4)
