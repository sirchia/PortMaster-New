#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

GAMEDIR="/$directory/ports/skijump3"
cd $GAMEDIR

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "SJ3" -c "$GAMEDIR/skijump3.gptk.$ANALOGSTICKS" &
LD_LIBRARY_PATH="$GAMEDIR/libs" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./SJ3 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1