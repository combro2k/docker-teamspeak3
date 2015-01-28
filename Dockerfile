###############################################
# Ubuntu with added Teamspeak 3 Server. 
# Uses SQLite Database on default.
###############################################

# Using latest Ubuntu image as base
FROM ubuntu

MAINTAINER Alex

## Set some variables for override.
# Download Link of TS3 Server
ENV TEAMSPEAK_URL http://dl.4players.de/ts/releases/3.0.11.2/teamspeak3-server_linux-amd64-3.0.11.2.tar.gz

RUN apt-get update && apt-get install -qy mariadb-client-5.5
ADD libmysqlclient.so.15.0.0 /usr/lib/x86_64-linux-gnu/libmysqlclient.so.15.0.0
RUN ln -s ln -s /opt/teamspeak3-server_linux-amd64/redist/libmariadb.so.2 /usr/lib/x86_64-linux-gnu/libmariadb.so.2

# Inject a Volume for any TS3-Data that needs to be persisted or to be accessible from the host. (e.g. for Backups)
VOLUME ["/teamspeak3"]

# Download TS3 file and extract it into /opt.
ADD ${TEAMSPEAK_URL} /opt/
RUN cd /opt && tar -xzf /opt/teamspeak3-server_linux-amd64-3.0.11.2.tar.gz

ADD /scripts/ /opt/scripts/
RUN chmod -R 774 /opt/scripts/

ENTRYPOINT ["/opt/scripts/docker-ts3.sh"]
#CMD ["-w", "/teamspeak3/query_ip_whitelist.txt", "-b", "/teamspeak3/query_ip_blacklist.txt", "-o", "/teamspeak3/logs/", "-l", "/teamspeak3/"]

# Expose the Standard TS3 port.
EXPOSE 9987/udp 10011/tcp 30033/tcp
