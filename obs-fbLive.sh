#!/bin/bash
# Req:
#   - epicsf fork of OBS that inclues --stats flag
#   - jq : https://stedolan.github.io/jq/
set -uf -o pipefail
OBS_PATH="/Users/epic/obs-studio"
PROFILE_PATH="$OBS_PATH/build-fblive/rundir/RelWithDebInfo/config/obs-studio/basic/profiles"

# TODO: SSH into Isaiah

read -p "Input FB Live Stream Key (Planning Center -> Notes): " -n 52 -r streamkey
echo

if [ ! -e "$PROFILE_PATH/FB_Live/service.json" ]; then
	echo "Cannot find obs profiles"
	exit 1
fi

# Set stream key and recreate profile file
jq --arg tmp "$streamkey" '.settings.key|="\($tmp)"' $PROFILE_PATH/FB\ Live/service.json > foo.json
mv foo.json $PROFILE_PATH/FB_Live/service.json

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
cd $OBS_PATH/build-fblive/rundir/RelWithDebInfo/bin/
./obs -p -m --verbose --stats --profile "FB_Live" --startstreaming | f
