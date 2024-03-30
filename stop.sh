#!/bin/bash

webserverLabel="app=whitenoise-hls-webserver"
ffmpegLabel="app=whitenoise-streams-generator"

function getContainerName {
  cId=$1
  name=$(docker inspect --format '{{.Name}}' $cId)
  echo "$name"
}

function getContainerImage {
  cId=$1
  image=$(docker inspect --format '{{.Config.Image}}' $cId)
  echo "$image"
}

function prettyDispContainer {
  name=$(getContainerName $cId)
  imageName=$(getContainerImage $cId)
  echo "ID: $cId, Name: $name, Image: $imageName"
}

containersToBeStopped=()

runningFFmpegContainers=($(docker ps --filter label=$ffmpegLabel --format '{{.ID}}'))
numContainers=${#runningFFmpegContainers[@]}
if [[ "$numContainers" = "0" ]]; then
  echo "No running FFmpeg containers, skip."
else
  echo "$numContainers running FFmpeg container(s): "
  for cId in ${runningFFmpegContainers[@]}; do
    echo $(prettyDispContainer $cId)
    containersToBeStopped+=($cId)
  done
fi
echo -ne '\n'

runningHLSPublishWebServerContainers=($(docker ps --filter label=$webserverLabel --format '{{.ID}}'))
numContainers=${#runningHLSPublishWebServerContainers[@]}
if [[ "$numContainers" = "0" ]]; then
  echo "No running HLS publishers, skip."
else
  echo "$numContainers running HLS publisher(s): "
  for cId in ${runningHLSPublishWebServerContainers[@]}; do
    echo $(prettyDispContainer $cId)
    containersToBeStopped+=($cId)
  done
fi
echo -ne '\n'

if [ ${#containersToBeStopped[@]} -eq 0 ]; then
  echo "Nothing do to."
else 
  for cId in ${containersToBeStopped[@]}; do
      echo -n "Stopping container $cId ... "
      docker stop $cId > /dev/null
      if [ $? -eq 0 ]; then
        echo -n "done."
      fi
      echo -ne '\n'
  done
fi
