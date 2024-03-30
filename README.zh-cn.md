# 白噪声和随机点阵图像生成器

## 简介

基于 ffmpeg 的随机点阵图像和白噪声生成器，支持以 HLS 串流格式输出。HLS 串流可在 Safari 浏览器或 VLC 播放器中播放。

通过该项目，我们演示了如何用 ffmpeg 生成随机音视频流、如何生产并（使用 nginx）发布 HLS 流等简单任务。

## 使用方式

1. 在初次部署时，构建镜像：

```
docker build -t whitenoise-generator:0.1 .
```

其中 image 名称要和 `start.sh` 脚本中变量 `whitenoiseGeneratorImageName` 引用的镜像匹配。

2. 启动 Web server 和 ffmpeg 实例：

```
./start.sh
```

## 屏幕截图

效果展示：

https://videos.idx.best/videos/demonstrations-24-03-30.mp4
