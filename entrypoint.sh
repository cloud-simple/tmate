#!/bin/bash
set -e

test -n "${USER_PAIR}" || \
  { echo "== err: env variable USER_PAIR is empty, should be a user to switch to for session sharing; exiting" ; sleep 10 ; exit ; }
test -n "${TMATE_API_KEY}" || \
  { echo "== err: env variable TMATE_API_KEY is empty, should be API Key from 'https://tmate.io/#api_key'; exiting" ; sleep 10 ; exit -1 ; }

for i in "$@" ; do 
  echo "== log: add public key for github user: $i"
  curl -fsS --max-time 50 -L https://github.com/${i}.keys >> /home/${USER_PAIR}/.ssh/authorized_keys
done

cat > /home/${USER_PAIR}/.tmate.conf << _EOF
set tmate-api-key "${TMATE_API_KEY}"
set tmate-session-name "ubuntu-22-04"
set tmate-authorized-keys "~/.ssh/authorized_keys"
_EOF

test ! -s /root/.tmux.conf || cat /root/.tmux.conf >> /home/${USER_PAIR}/.tmux.conf

PASS=${USER_PASSWORD:-$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c50)}
echo -e "== log: user to share session:\n   username: '${USER_PAIR}'\n   password: '${PASS}'"
echo "${USER_PAIR}:${PASS}" | chpasswd

echo "== log: su to '${USER_PAIR}' and start 'tmate -F new-session'"
su -l ${USER_PAIR} -c "/usr/bin/tmate -F new-session"
