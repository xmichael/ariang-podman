# ariang-podman
A (highly) opinionated podman container for a simple no-nonsense [AriaNg](https://github.com/mayswind/AriaNg) / [Aria2](https://github.com/aria2/aria2) downloader and bittorrent client.

It is meant for people who prefer the podman philosophy ( a single container for everything, systemd to reap zombie processes ). This will not work with docker.

Differences with other docker containers:

1. You can actually login into your containers, create new users, check the logs, install new packages etc.
2. Pid 1 is systemd which is responsible for process management and zombie reaping.
3. Everything is self-contained in one container. No docker-compose, pods, kubernetes orchestration etc.
4. secure. user namespaces, rootless only.

## Building

Everything is in the Dockerfile. You will want to set the root password ROOT_PASS for login.

```
podman build --build-arg ROOT_PASS=supersecret -t ariang .
```

## Running with runtime arguments

1. Edit arguments.conf to set a password for both aria as well as the login shell
2. Run the container specifying a downloads folder e.g. *~/Documents/downloads* as follows. You can also use a different host:port than 127.0.0.1:3333.

```
podman run --env-file ./arguments.conf -it --rm -v ~/Documents/downloads:/downloads:U -p127.0.0.1:3333:3333  ariang
```

3. Open the browser at http://localhost:3333/fg/index.html

The GUI will run on your browser and the first time it runs you will need to set the url of aria2c json-rpc.
Use the URL *http://localhost:3333/bg/jsonrpc* and the secret you have specified in the arguments.conf file above.
