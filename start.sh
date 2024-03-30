#!/bin/bash

now=$(date +%s)
webInstanceName="whitenoise-hls-server-$now"
whitenoiseGeneratorInsanceName="whitenoise-generator-$now"

nginxImageName="nginx:1.25.4"
whitenoiseGeneratorImageName="docker.io/library/whitenoise-generator:0.1"
docker inspect "$whitenoiseGeneratorImageName" > /dev/null
if [ $? -ne 0 ]; then
  echo "Some docker image is not found."
  exit 1
fi

nginxDefaultWebroot="/usr/share/nginx/html"
nginxConfOverride="$(pwd)/nginx/conf.d"
whitenoiseGeneratorOutputPath="/live"

publishPort="10086"
if [ "$PUBLISH_PORT" ]; then
  publishPort="$PUBLISH_PORT"
fi

tempDir=$(mktemp -d)
if [ $? -ne 0 ]; then
  echo "Failed to create temporary directory."
  exit 1
fi

nginxConfigOverrideFlags=""
if [ "$NGINX_CONFIG_OVERRIDE_DIR" ]; then
  nginxConfigOverrideFlags="-v $NGINX_CONFIG_OVERRIDE_DIR:/etc/nginx/conf.d"
elif [ -d "nginx/conf.d" ]; then
  nginxConfigOverrideFlags="-v $(pwd)/nginx/conf.d:/etc/nginx/conf.d"
fi

webserverLabel="app=whitenoise-hls-webserver"
webServerContainerId=$(docker run \
  -l $webserverLabel \
  -dit --rm \
  --name $webInstanceName \
  -p "$publishPort:80" \
  -v $tempDir:$nginxDefaultWebroot \
  $nginxConfigOverrideFlags \
  $nginxImageName)

if [ $? -ne 0 ]; then
  echo "Failed to launch the webserver to publish HLS stream data."
  exit 1
fi

echo "Launched webserver container: $webServerContainerId"

ffmpegLabel="app=whitenoise-streams-generator"
ffmpegContainerId=$(docker run \
  -dit --rm \
  -l $ffmpegLabel \
  --name $whitenoiseGeneratorInsanceName \
  -v "$tempDir:$whitenoiseGeneratorOutputPath" \
  $whitenoiseGeneratorImageName)

if [ $? -ne 0 ]; then
  echo "Failed to launch the whitenoise generator."
  exit 1
fi

echo "Launched ffmpeg container: $ffmpegContainerId"

echo -ne '\n'

webbase="http://localhost:$publishPort"
mDNSWebbase="http://$(hostname):$publishPort"

echo "Audible video streams: "
echo "(in localhost): $webbase/av_mixed/now.m3u8"
echo "(in LAN, with mDNS): $mDNSWebbase/av_mixed/now.m3u8"
echo -ne '\n'
echo "Pure audio streams: "
echo "(in localhost): $webbase/audio/now.m3u8"
echo "(in LAN, with mDNS): $mDNSWebbase/audio/now.m3u8"
echo -ne '\n'
echo "To browser all available streams, visit: $webbase/"
echo -ne '\n'
echo "You might open it using Safari or VLC, and if you don't see anything after open it, try again after a few seconds."
echo "Notice that if your current docker context is not in localhost, then above address(es) might be incorrect."
