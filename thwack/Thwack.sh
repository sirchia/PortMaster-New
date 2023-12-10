#!/bin/bash
# PORTMASTER: thwack.zip, Thwack.sh

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

GAMEDIR=/$directory/ports/thwack/
CONFDIR="$GAMEDIR/conf/"

# Assume demo/jam version ...
THWACKPCK="thwack-jam.pck"
# ... but select full patched version if found ...
if [ -f "/$GAMEDIR/gamedata/Thwack-patched.pck" ]; then
  echo "found Thwack-patched.pck"
  THWACKPCK="Thwack-patched.pck"
# ... or patch full game if unpatched full version found
elif [ -f "/$GAMEDIR/gamedata/Thwack.pck" ]; then
  echo "patching Thwack.pck"
  export LD_LIBRARY_PATH=/$GAMEDIR/lib
  cd /$GAMEDIR/gamedata/
  $SUDO ../xdelta3 -d -s "Thwack.pck" "Thwack.xdelta" "Thwack-patched.pck"
  THWACKPCK="Thwack-patched.pck"
fi

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles
export XDG_CONFIG_HOME="$CONFDIR"
export XDG_DATA_HOME="$CONFDIR"

cd $GAMEDIR

runtime="frt_3.5.2"
if [ ! -f "$controlfolder/libs/${runtime}.squashfs" ]; then
  # Check for runtime if not downloaded via PM
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    echo "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info." > /dev/tty0
    sleep 5
    exit 1
  fi

  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${runtime}.squashfs"
fi

# Setup Godot
godot_dir="$HOME/godot"
godot_file="$controlfolder/libs/${runtime}.squashfs"
$ESUDO mkdir -p "$godot_dir"
$ESUDO umount "$godot_file" || true
$ESUDO mount "$godot_file" "$godot_dir"
PATH="$godot_dir:$PATH"

export FRT_NO_EXIT_SHORTCUTS=FRT_NO_EXIT_SHORTCUTS

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "$runtime" -c "./thwack.gptk" &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" "$runtime" --main-pack "gamedata/$THWACKPCK"

$ESUDO umount "$godot_dir"
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0

