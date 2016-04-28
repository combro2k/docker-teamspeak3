#!/bin/bash

trap '{ echo -e "error ${?}\nthe command executing at the time of the error was\n${BASH_COMMAND}\non line ${BASH_LINENO[0]}" && tail -n 10 ${INSTALL_LOG} && exit $? }' ERR

export DEBIAN_FRONTEND="noninteractive"

# Versions
export TEAMSPEAK_VERSION="3.0.12.4"

# Packages
export PACKAGES=(
	'mariadb-client'
	'curl'
	'sqlite3'
)

pre_install() {
	mkdir -p /opt/ts3server 2>&1 || return 1

	apt-get update -q 2>&1 || return 1
	apt-get install -yq ${PACKAGES[@]} 2>&1 || return 1

    chmod +x /usr/local/bin/* || return 1

    return 0
}

install_teamspeak3()
{
    curl -L --silent http://dl.4players.de/ts/releases/${TEAMSPEAK_VERSION}/teamspeak3-server_linux-amd64-${TEAMSPEAK_VERSION}.tar.bz2 \
        | tar jx -C /opt/ts3server --strip-components=1 || return 1

    ln -s /opt/ts3server/redist/libmariadb.so.2 /usr/lib/x86_64-linux-gnu/libmariadb.so.2 || return 1

    return 0
}

post_install() {
    apt-get autoremove 2>&1 || return 1
	apt-get autoclean 2>&1 || return 1
	rm -fr /var/lib/apt 2>&1 || return 1

	return 0
}

build() {
	if [ ! -f "${INSTALL_LOG}" ]
	then
		touch "${INSTALL_LOG}" || exit 1
	fi

	tasks=(
        'pre_install'
        'install_teamspeak3'
	)

	for task in ${tasks[@]}
	do
		echo "Running build task ${task}..." || exit 1
		${task} | tee -a "${INSTALL_LOG}" > /dev/null 2>&1 || exit 1
	done
}

if [ $# -eq 0 ]
then
	echo "No parameters given! (${@})"
	echo "Available functions:"
	echo

	compgen -A function

	exit 1
else
	for task in ${@}
	do
		echo "Running ${task}..." 2>&1  || exit 1
		${task} || exit 1
	done
fi
