#!/bin/bash
# Req:
#   - epicsf fork of OBS that inclues --stats flag
#   - jq : https://stedolan.github.io/jq/
set -uf -o pipefail
OBS_PATH="/Users/epic/obs-studio"
PROFILE_PATH="$OBS_PATH/build-primary/rundir/RelWithDebInfo/config/obs-studio/basic/profiles"

# TODO: SSH into Isaiah
# TODO: Find the actual profile name of the main stream

if [ ! -e "$PROFILE_PATH/Stream_Monkey_Primary/service.json" ]; then
	echo "Cannot find obs profiles"
	exit 1
fi

# Function to keep output on one line
f() {
	spin[0]=".   "
	spin[1]=" .  "
	spin[2]="  . "
	spin[3]="   ."
	i=0
	while read data; do
		if [[ $data == *"stats:"* ]]; then
			i=$(( (i+1) %4 ))
			printf "${spin[i]} %s" "$data"
			echo -ne "\033[0K\r"
		else
			echo $data
		fi
	done
}

# Run OBS
cd $OBS_PATH/build-primary/rundir/RelWithDebInfo/bin/
./obs -p -m --verbose --stats --profile "Stream_Monkey_Primary" --startstreaming | f
