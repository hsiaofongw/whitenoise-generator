#!/bin/sh

outputResolution="100x100"
if [ "$OUTPUT_RESOLUTION" ]; then
    outputResolution="$OUTPUT_RESOLUTION"
fi

outputFrameRateFps="20"
if [ "$OUTPUT_FPS" ]; then
    outputFrameRateFps="$OUTPUT_FPS"
fi

outputAudioSampleRateHz="48000"
if [ "$OUTPUT_ADO_SAMP_RATE" ]; then
    outputAudioSampleRateHz="$OUTPUT_ADO_SAMP_RATE"
fi

outputM3U8Location="/live/now.m3u8"
outputM3U8Dir=$(dirname $outputM3U8Location)
mkdir -p "$outputM3U8Dir"
if [ $? -ne 0 ]; then
    echo "Failed to create: $outputM3U8Dir"
    exit 1
fi

outputVideoBitrate="1000k"
if [ "$OUTPUT_VIDEO_BIT_RATE" ]; then
    outputVideoBitrate="$OUTPUT_VIDEO_BIT_RATE"
fi

outputAudioBitrate="320k"
if [ "$OUTPUT_ADO_BIT_RATE" ]; then
    outputAudioBitrate="$OUTPUT_ADO_BIT_RATE"
fi

dd if=/dev/urandom | ffmpeg \
  -re -f rawvideo -framerate "$outputFrameRateFps" -pixel_format yuv420p -video_size "$outputResolution" -i pipe:0 \
  -re -f u8 -sample_rate "$outputAudioSampleRateHz" -ch_layout stereo -i pipe:0 \
  -map 0:v \
  -map 1:a \
  -c:v libx264 -c:a aac -b:v "$outputVideoBitrate" -b:a "$outputAudioBitrate" \
  -f fifo -attempt_recovery 1 -drop_pkts_on_overflow 1 \
  -fifo_format hls -format_opts "hls_time=2:hls_list_size=10:hls_flags=delete_segments" \
  "$outputM3U8Location"