# Shell sessions sharing with [`tmate`](https://tmate.io)

## How to build

* To build and push [Docker image](https://hub.docker.com/r/cloudsimple/tmate) the following commands are used

```console
git clone https://github.com/cloud-simple/tmate.git && cd tmate
docker build -t cloudsimple/tmate:latest -t cloudsimple/tmate:v0.1.0 .
docker push cloudsimple/tmate:latest
docker push cloudsimple/tmate:v0.1.0
```

## How to run

### Using Kubernetes pod

* Define [`TMATE_API_KEY` env variable](https://tmate.io/#api_key) corresponding to you setup and create `tmate` Kubernetes secret

```console
export TMATE_API_KEY=${TMATE_API_KEY:-tmk-DDmpDfrscNzBkStS2W5EXAMPLE}
kubectl create secret generic tmate --from-literal=TMATE_API_KEY=${TMATE_API_KEY}
```

* You can also add password for OS user to `sudo` to `root` to the above Kubernetes secret by defining `USER_PASSWORD` env variable in the following way

> **Note**
>
> If you used the previous command, delete the `tmate` Kubernetes secret befor using this command

```console
export USER_PASSWORD=${USER_PASSWORD:-pwd-EXamplePAsswordFOrSUdo1234}
export TMATE_API_KEY=${TMATE_API_KEY:-tmk-DDmpDfrscNzBkStS2W5EXAMPLE}

kubectl create secret generic tmate \
  --from-literal=USER_PASSWORD=${USER_PASSWORD} \
  --from-literal=TMATE_API_KEY=${TMATE_API_KEY}
```

* Create Kubernetes pod using a template like in the following snippet

> **Note**
>
> Change the template's `spec.containers.args` to the list of GitHub users which will have access to you shared session via SSH using the public keys available from GitHub API `https://github.com/<username>.keys`

```console
kubectl create -f - << '_EOF'
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: tmate
  name: tmate
spec:
  containers:
  - name: tmate
    image: cloudsimple/tmate:latest
    args: ["aws-simple"]
    envFrom:
    - secretRef:
        name: tmate
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
_EOF
```

* Use the following command to see logs for the created above pod to find session user password (to switch to `root` using `sudo`) and SSH session URLs

```console
kubectl logs tmate
```

* Here is an example output for the above command

↳ output:
```
== log: add public key for github user: aws-simple
== log: user to share session:
   username: 'pair'
   password: 'xRd70rvNk7To-1uZbkymEXAMPLE1gyo_aI34pHq8piaVze7F1s'
== log: su to 'pair' and start 'tmate -F new-session'
To connect to the session locally, run: tmate -S /tmp/tmate-1099/xWhb6F attach
Using ~/.ssh/authorized_keys for access control
Connecting to ssh.tmate.io...
ssh session read only: ssh ro-4KdEXXAMPLEexampleEXAMPLE@nyc1.tmate.io
ssh session: ssh example-tmate/ubuntu-22-04@nyc1.tmate.io
```
