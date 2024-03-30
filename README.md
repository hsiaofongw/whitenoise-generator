# 白噪声和随机图像生成器

## 简介

基于 ffmpeg 的随机点阵图像和白噪声生成器，支持以 HLS 串流格式输出。HLS 串流可在 Safari 浏览器或 VLC 播放器中播放。

## 使用方式

1. 在初次部署时，构建镜像：

```
docker build -t whitenoise-generator:0.1 .
```

其中 image 名称要和 `start.sh` 脚本中变量 `whitenoiseGeneratorImageName` 的值一致。

2. 启动 Web server 和 ffmpeg 实例：

```
./start.sh
```
