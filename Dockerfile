FROM ubuntu:latest

RUN apt-get update

COPY ./setup.sh /setup.sh
RUN /setup.sh

ENTRYPOINT [ "/bin/bash", "-c", "/connect.sh && adb disconnect" ]