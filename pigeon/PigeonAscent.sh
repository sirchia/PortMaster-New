#!/bin/bash
# PORTMASTER: pigeon.zip, PigeonAscent.sh

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

GAMEDIR=/$directory/ports/PigeonAscent/
cd $GAMEDIR

if [[ "$(cat /sys/firmware/devicetree/base/model | tr -d '\0')" == "Anbernic RG552" ]]; then

  rm pigeon4-3.zip pigeontouch.gptk
  mv pigeon16-9.zip pigeonAscent.zip

else
  rm pigeon16-9.zip 
  mv pigeon4-3.zip pigeonAscent.zip
  mv pigeontouch.gptk pigeon.gptk
fi

export FRT_NO_EXIT_SHORTCUTS=FRT_NO_EXIT_SHORTCUTS

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "frt_3.5.2" -c "./pigeon.gptk" textinput &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./frt_3.5.2 --main-pack pigeonAscent.zip
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0