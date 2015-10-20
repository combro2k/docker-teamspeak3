#!/bin/bash

docker run -ti --rm --name teamspeak3 -P combro2k/docker-teamspeak3:latest ${@}
