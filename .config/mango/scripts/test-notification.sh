#!/usr/bin/env bash
set -u

mode="${1:-plain}"
random_image="$(find "$HOME/Pictures" -type f 2> /dev/null | shuf -n 1)"
account_image="/var/lib/AccountsService/icons/$USER"

if [ "$mode" = "body-image" ]; then
    action="$(notify-send "Test notification with body image" \
        "This notification should contain your user account <b>image</b> and <a href=\"https://discord.com/app\">Discord</a> <b>icon</b>. Oh and here is a random image in your Pictures folder: <img src=\"$random_image\" alt=\"Testing image\"/>" \
        -a "Mango" -p -h "string:image-path:$account_image" -t 6000 -i "discord" \
        -A "openImage=Profile image" -A "action2=Open the random image" -A "action3=Useless button")"
    [[ "$action" == *openImage* ]] && xdg-open "$account_image"
    [[ "$action" == *action2* ]] && xdg-open "$random_image"
else
    action="$(notify-send "Test notification" \
        "This notification should contain a random image in your <b>Pictures</b> folder and <a href=\"https://discord.com/app\">Discord</a> <b>icon</b>." \
        -a "Discord (fake)" -p -h "string:image-path:$random_image" -t 6000 -i "discord" \
        -A "openImage=Profile image" -A "action2=Useless button")"
    [[ "$action" == *openImage* ]] && xdg-open "$account_image"
fi
