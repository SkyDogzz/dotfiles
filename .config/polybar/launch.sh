#/bin/sh

killall -q polybar

#polybar example 2>&1 | tee -a /tmp/polybar.log & disown

for m in $(polybar --list-monitors | cut -d":" -f1); do
    MONITOR=$m polybar --reload example &
echo "Polybar launched"
done

