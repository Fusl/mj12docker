#!/usr/bin/env bash

function printhelp() {
cat << EOF
Usage: docker run -d -i -m 512M -t fusl/mj12node <arguments>

You *need* to run the docker container using the docker args as above,
otherwise MJ12node starts in foreground and you can only kill it using
'docker kill <container id>' from another terminal (Ctrl-C won't work).

Arguments: --username=<username>  -  mandatory
           --password=<password>  -  mandatory
           --email=<email>        -  mandatory
           --maxworkers=<max num of workers (1)>
           --maxopenbuckets=<max num of open buckets (1)>
           --connection-downstream=<download bandwidth in kbit/s (1000)>
           --connection-upstream=<upload bandwidth in kbit/s (1000)>
           --connection-downstream-limit=<download bandwidth MJ12 is
                                          allowed to use (1000)>
           --connection-upstream-limit=<upload bandwidth MJ12 is allowed
                                        to use (1000)>

Arguments marked with * are mandatory
EOF
}
if [ "x${1}" == "x--help" ]; then
	printhelp
	exit 0
fi
provided_username=""
provided_password=""
provided_email=""
for arg in "$@"; do
	if echo -n "${arg}" | grep -qE -- "^--username="; then
		provided_username=$(echo -n "${arg}" | sed 's/^--username=//')
	fi
	if echo -n "${arg}" | grep -qE -- "^--password="; then
		provided_password=$(echo -n "${arg}" | sed 's/^--password=//')
	fi
	if echo -n "${arg}" | grep -qE -- "^--email="; then
		provided_email=$(echo -n "${arg}" | sed 's/^--email=//')
	fi
done
if [ "x${provided_username}" == "x" ] || [ "x${provided_password}" == "x" ] || [ "x${provided_email}" == "x" ]; then
	echo "Missing at least one mandatory argument"
	printhelp
	exit 1
fi
cd /home/mj12/MJ12node/
su -c 'mono MJ12nodeMono.exe --activityperiod=0 --exthelper --identitynodename=docker${HOSTNAME} --peernodename=docker${HOSTNAME} --maxworkers=1 --maxopenbuckets=1 --connection-downstream=1000 --connection-upstream=1000 --connection-downstream-limit=1000 --connection-upstream-limit=1000 "${@}"' mj12 -- "${@}"
