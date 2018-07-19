FROM mono:latest
MAINTAINER Fusl <fusl@meo.ws>
EXPOSE 1088

COPY files/ /
RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y libc6:i386 curl \
 && rm -rf /var/lib/apt/lists/* \
 && useradd mj12 \
 && mkdir -p /home/mj12/MJ12node/ \
 && curl https://www.majestic12.co.uk/files/mj12node/mono/mj12node_linux_v1715_net45_up25.tgz | tar -xzC /home/mj12/MJ12node/ --strip-components=1 \
 && chown -R mj12:mj12 /home/mj12/
ENTRYPOINT ["/run-mj12.sh"]
