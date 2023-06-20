FROM ubuntu:latest

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get -qqy upgrade \
 && DEBIAN_FRONTEND=noninteractive apt-get -qqy install openssh-server tmux tmate curl vim sudo

ENV USER_PAIR=pair

RUN useradd --comment '${USER_PAIR}' --uid 1099 --user-group --create-home --shell /bin/bash ${USER_PAIR} \
 && mkdir /home/${USER_PAIR}/.ssh \
 && touch /home/${USER_PAIR}/.ssh/authorized_keys \
 && chmod 700 /home/${USER_PAIR}/.ssh \
 && chmod 600 /home/${USER_PAIR}/.ssh/authorized_keys \
 && touch /home/${USER_PAIR}/.tmate.conf \
 && chown -R ${USER_PAIR}:${USER_PAIR} /home/${USER_PAIR} \
 && usermod -aG sudo ${USER_PAIR}

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
