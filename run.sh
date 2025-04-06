#!/usr/bin/env bash

source env.sh

if [[ -z $IP ]]; then
    IP_ARGS=""
else
    IP_ARGS="-ip ${IP}"
fi

# https://developer.valvesoftware.com/wiki/Command_line_options
steamcmd \
    +api_logging 1 1 \
    +@sSteamCmdForcePlatformType linux \
    +@sSteamCmdForcePlatformBitness 64 \
    +force_install_dir $PWD/cs2 \
    +login anonymous \
    +app_update 730 \
    +quit

# Define the file name
FILE="./cs2/game/csgo/gameinfo.gi"

# Define the pattern to search for and the line to add
PATTERN="Game_LowViolence[[:space:]]*csgo_lv // Perfect World content override"
LINE_TO_ADD="\t\t\tGame\tcsgo/addons/metamod"

# Use a regular expression to ignore spaces when checking if the line exists
REGEX_TO_CHECK="^[[:space:]]*Game[[:space:]]*csgo/addons/metamod"

# Check if the line already exists in the file, ignoring spaces
if grep -qE "$REGEX_TO_CHECK" "$FILE"; then
    echo "$FILE already patched for Metamod."
else
    # If the line isn't there, use awk to add it after the pattern
    awk -v pattern="$PATTERN" -v lineToAdd="$LINE_TO_ADD" '{
        print $0;
        if ($0 ~ pattern) {
            print lineToAdd;
        }
    }' "$FILE" >tmp_file && mv tmp_file "$FILE"
    echo "$FILE successfully patched for Metamod."
fi

mkdir -p run

echo "Merging custom files & mods"

UPPER=$PWD/upper
DIR1=$PWD/custom_files
DIR2=$PWD/mods
DIR3=$PWD/cs2
DST_DIR=$PWD/run
sudo mount -t overlay overlay -o lowerdir=$DIR1:$DIR2:$DIR3,upperdir=$UPPER,workdir=$PWD/.work $DST_DIR
trap 'sudo umount $DST_DIR' EXIT

exit

# https://developer.valvesoftware.com/wiki/Counter-Strike_2/Dedicated_Servers#Command-Line_Parameters
sudo -u $USER ./run/game/bin/linuxsteamrt64/cs2 \
    -dedicated \
    -console \
    -usercon \
    -autoupdate \
    -tickrate "$TICKRATE" \
    "$IP_ARGS" \
    -port "$PORT" \
    +map "${MAP-de_dust2}" \
    +sv_visiblemaxplayers "$MAXPLAYERS" \
    -authkey "$API_KEY" \
    +sv_setsteamaccount "$STEAM_ACCOUNT" \
    +game_type "${GAME_TYPE-0}" \
    +game_mode "${GAME_MODE-0}" \
    +mapgroup "${MAP_GROUP-mg_active}" \
    +sv_lan "$LAN" \
    +sv_password "$SERVER_PASSWORD" \
    +rcon_password "$RCON_PASSWORD" \
    +exec "$EXEC"
