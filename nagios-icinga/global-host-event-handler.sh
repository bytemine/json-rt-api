#!/bin/sh

# $HOSTSTATE$ $HOSTSTATETYPE$ $HOSTNAME$ $HOSTOUTPUT$ $HOSTPROBLEMID$ $LASTPROBLEMID$

notify_rt()
{
	local hostname="$1"
	local state="$2"
	local output="$3"
	local statetype="$4"
	local problemid="$5"
	local lastproblemid="$6"

	/etc/icinga/bin/notify_rt.sh --NOTIFICATION_METHOD rt_host --RTURL https://rt-api.example.com/icinga/host_notification --HOSTNAME $hostname --HOSTSTATE $state --HOST_STATE_TYPE $statetype --HOSTPROBLEMID $problemid --LASTHOSTPROBLEMID $lastproblemid --HOSTOUTPUT="$output" --RTAUTH "rt-api:secret_password"
}

# We only care for HARD states for now.
if [ "$2" = "SOFT" ]; then
	exit 0
fi

case "$1" in
UP)
	notify_rt "$3" "$1" "$4" "$2" "$5" "$6"
	;;
UNREACHABLE)
	notify_rt "$3" "$1" "$4" "$2" "$5" "$6"
	;;
DOWN)
	notify_rt "$3" "$1" "$4" "$2" "$5" "$6"
	;;
esac

exit 0
