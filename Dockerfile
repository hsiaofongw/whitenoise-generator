FROM docker.io/linuxserver/ffmpeg:latest

WORKDIR /app
COPY entrypoint.sh .

ENTRYPOINT [ "/app/entrypoint.sh" ] 
