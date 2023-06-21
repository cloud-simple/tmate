### image to be used as a base for the other images here
FROM ubuntu:latest AS base

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get -qqy upgrade \
 && DEBIAN_FRONTEND=noninteractive apt-get -qqy install libevent-dev ncurses-dev

### build tmux from source from github repo
FROM base AS build-tmux

RUN DEBIAN_FRONTEND=noninteractive apt-get -qqy install automake bison build-essential git pkg-config

RUN git clone https://github.com/tmux/tmux.git \
 && cd tmux \
 && sh autogen.sh \
 && ./configure \
 && make \
 && make install

### target app image
FROM base AS app

RUN mkdir -p /usr/local/bin \
 && mkdir -p /usr/local/share/man/man1

COPY --from=build-tmux /usr/local/bin/tmux /usr/local/bin/
COPY --from=build-tmux /usr/local/share/man/man1/tmux.1 /usr/local/share/man/man1/

RUN DEBIAN_FRONTEND=noninteractive apt-get -qqy install openssh-server tmate curl vim sudo

ENV USER_PAIR=pair

RUN useradd --comment '${USER_PAIR}' --uid 1099 --user-group --create-home --shell /bin/bash ${USER_PAIR} \
 && mkdir /home/${USER_PAIR}/.ssh \
 && touch /home/${USER_PAIR}/.ssh/authorized_keys \
 && chmod 700 /home/${USER_PAIR}/.ssh \
 && chmod 600 /home/${USER_PAIR}/.ssh/authorized_keys \
 && touch /home/${USER_PAIR}/.tmate.conf \
 && touch /home/${USER_PAIR}/.tmux.conf \
 && chown -R ${USER_PAIR}:${USER_PAIR} /home/${USER_PAIR} \
 && usermod -aG sudo ${USER_PAIR}

COPY .tmux.conf /root/

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

