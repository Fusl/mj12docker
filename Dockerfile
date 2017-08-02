FROM ubuntu:16.04
MAINTAINER Fusl <fusl@meo.ws>
EXPOSE 1088

RUN (echo 'APT::Install-Recommends "0";'; echo 'APT::Install-Suggests "0";') > /etc/apt/apt.conf.d/01norecommend
RUN echo 'deb http://download.mono-project.com/repo/debian wheezy main' > /etc/apt/sources.list.d/mono-xamarin.list

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN dpkg --add-architecture i386
RUN apt-get update && apt-get install -y libc6:i386 mono-complete libmono-corlib4.5-cil libmono-sqlite4.0-cil curl

RUN ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime
RUN dpkg-reconfigure -f noninteractive tzdata

COPY files/ /
RUN useradd mj12
RUN curl http://www.majestic12.co.uk/files/mj12node/mono/mj12node_linux_v1715_net45_up25.tgz | tar -xzC /home/mj12/MJ12node/ --strip-components=1
RUN chown -R mj12:mj12 /home/mj12/
ENTRYPOINT ["/run-mj12.sh"]
