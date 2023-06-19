FROM ubuntu:latest

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get upgrade -qqy \
 && DEBIAN_FRONTEND=noninteractive apt-get install -qqy \
      openssh-server \
      tmux \
      tmate \
      curl \
      vim \
      sudo
