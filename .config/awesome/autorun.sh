#/bin/sh

run(){
  if
    ! pgrep -f "$1" ;
  then
    "$@"&
  fi
}

run $HOME/.config/polybar/launch.sh
run picom -b
