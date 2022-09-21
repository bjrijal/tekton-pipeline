FROM ubuntu:latest
RUN apt install libfuse3-dev
ENTRYPOINT echo hello medium
