#!/bin/sh

# $SERVICESTATE$ $SERVICESTATETYPE$ $HOSTNAME$ $SERVICEDESC$ $SERVICEOUTPUT$ $SERVICEPROBLEMID$ $LASTSERVICEPROBLEMID$

notify_rt()
{
	local hostname="$1"
	local desc="$2"
	local state="$3"
	local output="$4"
	local statetype="$5"
	local problemid="$6"
	local lastproblemid="$7"

	/etc/icinga/bin/notify_rt.sh --NOTIFICATION_METHOD rt_service --RTURL https://rt-api.example.com/icinga/service_notification --SERVICEPROBLEMID $problemid --LASTSERVICEPROBLEMID $lastproblemid --SERVICE_STATE_TYPE $statetype --HOSTNAME $hostname --SERVICEDESC "$desc" --SERVICESTATE $state --SERVICEOUTPUT="$output" --RTAUTH "rt-api:secret_password"
}

# We only care for HARD states for now.
if [ "$2" = "SOFT" ]; then
	exit 0
fi

case "$1" in
OK)
	notify_rt "$3" "$4" "$1" "$5" "$2" "$6" "$7"
	;;
WARNING)
	notify_rt "$3" "$4" "$1" "$5" "$2" "$6" "$7"
	;;
UNKNOWN)
	notify_rt "$3" "$4" "$1" "$5" "$2" "$6" "$7"
	;;
CRITICAL)
	notify_rt "$3" "$4" "$1" "$5" "$2" "$6" "$7"
	;;
esac

exit 0
