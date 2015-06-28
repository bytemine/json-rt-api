#!/bin/bash

# Script originates from http://iambenjaminlong.com/software-projects/notify_rt/

# The higher this number, the more debug output you get. 0 is 100% silent. Max=3.
# You can override this on the command line with "--DEBUGLEVEL <lvl>" as the FIRST "--" option.
DEBUGLEVEL=3

# Functions
function debug {
# Takes two arguments:
#<Debuglevel>
#<Message>

  if [ $DEBUGLEVEL -ge $1 ]; then
    case "$1" in
    1|2|3) # Debug levels that output something
      echo "$2" 1>&2
      ;;
    0) # Debug level thats 100% Silent
      ;;
    *) # Other, invalid debug levels
      echo "WARNING: Invalid Debug Level $1! I'm outputting everything to be safe." 1>&2
      echo $2 1>&2
      ;;
    esac
  fi
}

function rt_config {
	# Make sure RT login variables are set
	if [ -z "$RTURL" ]; then
		echo "Need to specify RTURL"
		exit 1
	fi

	# Export RT config vars
	export RTURL
}

function send_rt_service {
	# Make sure Nagios host problem ID's were set.
	if 	[[ -z "$SERVICEPROBLEMID" ]] || \
			[[ -z "$LASTSERVICEPROBLEMID" ]] || \
			[[ -z "$HOSTNAME" ]] || \
			[[ -z "$SERVICEDESC" ]] || \
			[[ -z "$SERVICE_STATE_TYPE" ]] || \
			[[ -z "$SERVICESTATE" ]] \
			;then
		echo "SERVICEPROBLEMID, LASTSERVICEPROBLEMID, HOSTNAME, SERVICEDESC, SERVICE_STATE_TYPE and/or SERVICESTATE variables not set"
		exit 1
	fi
	
	# RT API call
  curl -m 5 -u $RTAUTH -X POST -H Content-Type:application/json $RTURL -d "
    { \"problem_id\": \"${SERVICEPROBLEMID}\",
      \"last_problem_id\": \"${LASTSERVICEPROBLEMID}\", 
      \"hostname\": \"${HOSTNAME}\", 
      \"state\": \"${SERVICESTATE}\", 
      \"state_type\": \"${SERVICE_STATE_TYPE}\",
      \"description\": \"${SERVICEDESC}\",
      \"output\": \"${SERVICEOUTPUT}\"
    }"

}

function send_rt_host {
	# Make sure Nagios host problem ID's were set.
	if 	[[ -z "$HOSTPROBLEMID" ]] || \
			[[ -z "$LASTHOSTPROBLEMID" ]] || \
			[[ -z "$HOSTNAME" ]] || \
			[[ -z "$HOST_STATE_TYPE" ]] || \
			[[ -z "$HOSTSTATE" ]] \
			;then
		echo "HOSTPROBLEMID, LASTHOSTPROBLEMID, HOSTNAME, HOST_STATE_TYPE and/or HOSTSTATE variables not set"
		exit 1
	fi
	
	# RT API call
	curl -m 5 -u $RTAUTH -X POST -H Content-Type:application/json $RTURL -d "
    { \"problem_id\": \"${HOSTPROBLEMID}\",
      \"last_problem_id\": \"${LASTHOSTPROBLEMID}\", 
      \"hostname\": \"${HOSTNAME}\", 
      \"state\": \"${HOSTSTATE}\", 
      \"state_type\": \"${HOST_STATE_TYPE}\",
      \"output\": \"${HOSTOUTPUT}\"
    }"
}

########################################
# MAIN CODE                            #
########################################

# Loop though command line arguments
index=0
for argument in $@; do
	let index=index+1
	if [[ $argument == --* ]]; then
		if [[ $argument == -- ]]; then
			break
		fi
		ARG=${argument#--}
		declare $ARG="$(grep -oP "(?<=$argument).*?(?=--|$)" <<< "${@}" | sed -e 's/^ *//g' -e 's/ *$//g')"
		debug 2 "$ARG=[${!ARG}]"
	fi
done

# Run RT config setup function
rt_config

case $NOTIFICATION_METHOD in
	"rt_host") # Create/Append/Resolve Request Tracker Ticket for Host
		send_rt_host
	;;
	"rt_service") # Create/Append/Resolve Request Tracker Ticket for Host
		send_rt_service
	;;
	*|'') # Unknown method
		echo "Unknown Notification Method: $NOTIFICATION_METHOD"
		exit 3
	;;
esac
		
