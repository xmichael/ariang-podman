# Systemd debian container where you can login
### CHECK THE ARGS BELOW

FROM debian:testing

MAINTAINER xmichael

RUN export DEBIAN_FRONTEND=noninteractive; \
    export DEBCONF_NONINTERACTIVE_SEEN=true; \
    apt-get update -qq && \
    apt-get upgrade -y && \
    apt-get install -y systemd systemd-container bash-completion procps caddy aria2 unzip curl && \
    apt-get --quiet autoremove --yes && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#### ARGS ####
ARG ARIANG_RELEASE="https://github.com/mayswind/AriaNg/releases/download/1.3.8/AriaNg-1.3.8.zip"
ARG ARIANG_SUM="26bbf8d22803cf125aaabc8c33b3454a"
ARG ROOT_PASS="changeme"
# s.a. ./arguments.conf for runtime environment options
#       podman run --env-file=./arguments.conf ...)
##############

# Set default root pass
RUN echo "root:${ROOT_PASS}" | chpasswd
# Create passwordless user "user"
RUN adduser --disabled-password --comment "" user

WORKDIR /root

# Copy service files
COPY units/*.service /etc/systemd/system/
# Autostart on boot
RUN systemctl enable aria2c caddy fixdirs
# populate /root
COPY conf/README /root/
# init.sh is called by fixdirs.service on boot
COPY conf/init.sh /root/

# aria files
RUN mkdir /home/user/aria
COPY conf/Caddyfile /home/user/aria/
COPY conf/aria2.conf /home/user/aria/

# Download AriaNg using aria2c
RUN aria2c "${ARIANG_RELEASE}"
# build will fail if md5sum does not match
RUN bash -c 'md5sum -c <<< "${ARIANG_SUM}  AriaNg-1.3.8.zip"'
RUN unzip -q -d /home/user/aria/ariang AriaNg-1.3.8.zip && rm AriaNg-1.3.8.zip

# /downloads volume
# either 1. mount as guest root with chmod 777 or 
# use the "U" flag -v~/downloads:/downloads:U και κανει οτι αλλαγες θελεις (chown etc.) στον guest
# Αν θες μετα να κάνει rm, mv etc απο host χωρις permission error κανε:
# podman unshare rm ~/downloads/<file>

# volumen (-v) permissions are reset on podman run -v unless you fix them in conf/init.sh after boot
# with :U flag
RUN mkdir /downloads
RUN chown -R user:user /downloads /home/user/aria

## This is just for documentation (you still need -p and -v anyway)
EXPOSE 3333
VOLUME /downloads

# systemd must be pid 1 to work
CMD [ "/lib/systemd/systemd" ]
