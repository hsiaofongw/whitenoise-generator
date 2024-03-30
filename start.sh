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

docker run -dit --rm --name $webInstanceName \
  -p "$publishPort:80" \
  -v $tempDir:$nginxDefaultWebroot \
  $nginxConfigOverrideFlags \
  $nginxImageName

if [ $? -ne 0 ]; then
  echo "Failed to launch the webserver to publish HLS stream data."
  exit 1
fi

docker run -dit --rm --name $whitenoiseGeneratorInsanceName \
  -v "$tempDir:$whitenoiseGeneratorOutputPath" \
  $whitenoiseGeneratorImageName

if [ $? -ne 0 ]; then
  echo "Failed to launch the whitenoise generator."
  exit 1
fi

streamingEndpointLocal="http://localhost:$publishPort/now.m3u8"
streamingEndpointLAN="http://$(hostname):$publishPort/now.m3u8"

echo "HLS endpoint (in localhost): $streamingEndpointLocal"
echo "HLS endpoint (in LAN, with mDNS hostname): $streamingEndpointLAN"
echo "You might open it using Safari or VLC, and if you don't see anything after open it, try again after a few seconds."
