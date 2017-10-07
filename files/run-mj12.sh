#!/usr/bin/env bash

function cleanup() {
	echo "Cleaning up..."
	kill -SIGKILL "${1}"
}
function printhelp() {
cat << EOF
Usage: docker run --rm -d -m 512M fusl/mj12node -n... -p... -e... [OPTIONS]

You *need* to run the docker container using the docker options as above,
otherwise MJ12node starts in foreground and you can only kill it using
'docker kill <container id>' from another terminal (Ctrl-C won't work).

  -h, --help       Print this help text
  -n, --username   Account username
  -p, --password   Account password
  -e, --email      Account email address
  -w, --workers    Maximum number of workers [1]
  -b, --buckets    Maximum number of open buckets [1]
  -d, --downstream Available download bandwidth for Majestic-12 in kbit/s [1000]
  -u, --upstream   Available upload bandwidth for Majestic-12 in kbit/s [1000]
  -s, --webserver  Enable webserver on port 1088

EOF
}
function printlicense() {
cat << EOF
The Majestic-12 binaries and files included with the Docker image distributed at
  https://hub.docker.com/r/fusl/mj12node/ are copyright of the Majestic-12 Ltd.:
    Faraday Wharf
    Holt Street
    Birmingham Science Park, Aston
    Birmingham
    B7 4BB
    United Kingdom
  Re-distribution of those files is STRICTLY FORBIDDEN.

This software package is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE.

EOF
}

OPT_USERNAME=""
OPT_PASSWORD=""
OPT_EMAIL=""
OPT_WORKERS="1"
OPT_BUCKETS="1"
OPT_DOWNSTREAM="1000"
OPT_UPSTREAM="1000"
OPT_WEBSERVER=""

function parseoption() {
	echo -n "${*}" | sed -r 's/^(--[a-z]+=|--[a-z]+$|-[a-z]=|-[a-z])//'
}
function parseoptions() {
	while [ "x${#}" != "x0" ]; do
		local value=""
		case "${1}" in
			-h*|--help|--help=*)
				printhelp
				printlicense
				exit 1
			;;
			-n*|--username|--username=*)
				value=$(parseoption "${1}")
				[ "x${value}" == "x${1}" ] && value=""
				[ "x${value}" == "x" ] && [ "x${2:0:1}" != "x-" ] && value="${2}" && shift
				OPT_USERNAME="${value}"
			;;
			-p*|--password|--password=*)
				value=$(parseoption "${1}")
				[ "x${value}" == "x${1}" ] && value=""
				[ "x${value}" == "x" ] && [ "x${2:0:1}" != "x-" ] && value="${2}" && shift
				OPT_PASSWORD="${value}"
			;;
			-e*|--email|--email=*)
				value=$(parseoption "${1}")
				[ "x${value}" == "x${1}" ] && value=""
				[ "x${value}" == "x" ] && [ "x${2:0:1}" != "x-" ] && value="${2}" && shift
				OPT_EMAIL="${value}"
			;;
			-w*|--workers|--workers=*)
				value=$(parseoption "${1}")
				[ "x${value}" == "x${1}" ] && value=""
				[ "x${value}" == "x" ] && [ "x${2:0:1}" != "x-" ] && value="${2}" && shift
				OPT_WORKERS="${value}"
			;;
			-b*|--buckets|--buckets=*)
				value=$(parseoption "${1}")
				[ "x${value}" == "x${1}" ] && value=""
				[ "x${value}" == "x" ] && [ "x${2:0:1}" != "x-" ] && value="${2}" && shift
				OPT_BUCKETS="${value}"
			;;
			-d*|--downstream|--downstream=*)
				value=$(parseoption "${1}")
				[ "x${value}" == "x${1}" ] && value=""
				[ "x${value}" == "x" ] && [ "x${2:0:1}" != "x-" ] && value="${2}" && shift
				OPT_DOWNSTREAM="${value}"
			;;
			-u*|--upstream|--upstream=*)
				value=$(parseoption "${1}")
				[ "x${value}" == "x${1}" ] && value=""
				[ "x${value}" == "x" ] && [ "x${2:0:1}" != "x-" ] && value="${2}" && shift
				OPT_UPSTREAM="${value}"
			;;
			-s*|--webserver|--webserver=*)
				value=$(parseoption "${1}")
				[ "x${value}" == "x${1}" ] && value=""
				[ "x${value}" == "x" ] && [ "x${2:0:1}" != "x-" ] && value="${2}" && shift
				OPT_WEBSERVER="1"
			;;
			*)
				printhelp
				printlicense
				exit 1
			;;
		esac
		shift
	done
}
is_int() {
	case "${*}" in
		''|*[!0-9]*) return 1 ;;
		*) return 0 ;;
	esac
}
is_between() {
	if ! is_int "${1}" || test "${1}" "-le" "${2}" || test "${1}" "-ge" "${3}"; then
		return 1
	fi
	return 0
}
parseoptions "${@}"

if test -z "${OPT_USERNAME// }"            ||
   test -z "${OPT_PASSWORD// }"            ||
   test -z "${OPT_EMAIL// }"               ||
 ! is_between "${OPT_WORKERS}"    0 501    ||
 ! is_between "${OPT_BUCKETS}"    0 201    ||
 ! is_between "${OPT_DOWNSTREAM}" 0 100001 ||
 ! is_between "${OPT_UPSTREAM}"   0 100001; then
	printhelp
	printlicense
	exit 1
fi

printlicense

MJ12_OPT_activityperiod="--activityperiod=0"
MJ12_OPT_connection_downstream="--connection-downstream=${OPT_DOWNSTREAM}"
MJ12_OPT_connection_downstream_limit="--connection-downstream-limit=100"
MJ12_OPT_connection_upstream="--connection-upstream=${OPT_UPSTREAM}"
MJ12_OPT_connection_upstream_limit="--connection-upstream-limit=100"
MJ12_OPT_email="--email=${OPT_EMAIL}"
MJ12_OPT_exthelper="--exthelper"
MJ12_OPT_identitynodename="--identitynodename=docker${HOSTNAME}"
MJ12_OPT_maxopenbuckets="--maxopenbuckets=${OPT_BUCKETS}"
MJ12_OPT_maxworkers="--maxworkers=${OPT_WORKERS}"
MJ12_OPT_password="--password=${OPT_PASSWORD}"
MJ12_OPT_peernodename="--peernodename=docker${HOSTNAME}"
MJ12_OPT_username="--username=${OPT_USERNAME}"
MJ12_OPT_startweb=$(test "x${OPT_WEBSERVER}" "==" "x1" && echo -n "-s")

configdate=$(date +%Y-%m-%d)

cat /config.xml.tpl | sed "
s~{{MJ12node>WebCrawlerCfg:LastCleanUp}}~${configdate}~g;
s~{{MJ12node>WebCrawlerCfg>Crawling:MaxOpenBuckets}}~${OPT_BUCKETS}~g;
s~{{MJ12node>IdentityCfg:EmailAddress}}~${OPT_EMAIL}~g;
s~{{MJ12node>IdentityCfg:NickName}}~${OPT_USERNAME}~g;
s~{{MJ12node>IdentityCfg:NodeName}}~${HOSTNAME}~g;
s~{{MJ12node>PeerNodeCfg:NodeName}}~docker${HOSTNAME}~g;
s~{{MJ12node>Connection:DownStream}}~${OPT_DOWNSTREAM}~g;
s~{{MJ12node>Connection:UpStream}}~${OPT_UPSTREAM}~g
" > /home/mj12/MJ12node/config.xml

cd /home/mj12/MJ12node/
exec su -c 'exec mono MJ12nodeMono.exe "${@}"' mj12 -- \
	"${MJ12_OPT_activityperiod}" \
	"${MJ12_OPT_connection_downstream}" \
	"${MJ12_OPT_connection_downstream_limit}" \
	"${MJ12_OPT_connection_upstream}" \
	"${MJ12_OPT_connection_upstream_limit}" \
	"${MJ12_OPT_email}" \
	"${MJ12_OPT_exthelper}" \
	"${MJ12_OPT_identitynodename}" \
	"${MJ12_OPT_maxopenbuckets}" \
	"${MJ12_OPT_maxworkers}" \
	"${MJ12_OPT_password}" \
	"${MJ12_OPT_peernodename}" \
	"${MJ12_OPT_username}" \
	${MJ12_OPT_startweb} \
&
pid="${!}"
trap "cleanup ${pid}" HUP INT QUIT KILL TERM
wait "${pid}"
exit 0

