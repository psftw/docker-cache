#!/bin/bash
set -x

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

# collection of cache/proxy containers!

# rawdns provides a Docker-aware DNS server.  You'll need to configure your
# Docker daemon to use it by default (i.e. "--dns 172.17.42.1"), and configure
# your host system's resolver as well.
#
# github.com/tianon/rawdns
docker run -d --restart=always --name rawdns \
	-p 53:53/udp -v /var/run/docker.sock:/var/run/docker.sock \
	-v $(pwd)/rawdns.json:/etc/rawdns.json:ro \
	tianon/rawdns rawdns /etc/rawdns.json

# apt-cacher-ng provides package caching for debian/ubuntu.  We specify --dns
# for this container so that it doesn't clash with rawdns.
#
# github.com/tianon/dockerfiles
docker run --name apt-cacher-ng-data \
	-v /var/cache/apt-cacher-ng --entrypoint /bin/echo \
	tianon/apt-cacher-ng "APT cache"
docker run -d --restart=always --name apt-cacher-ng \
	--volumes-from apt-cacher-ng-data \
	--dns 8.8.8.8 --dns 8.8.4.4 tianon/apt-cacher-ng

# artifactory provides an advanced proxy for java libraries.
#
# github.com/mattgruter/dockerfile-artifactory
#docker run -d --restart=always --name artifactory \
#	-h artifactory mattgruter/artifactory
