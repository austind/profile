function tmux_jumphost() {
    if [ -n "$TMUX" ]; then
        tmux rename-window "$(echo $2)"
        command ssh -A -t jumphost "$@"
        tmux set-window-option automatic-rename "on" 1>/dev/null
    else
        command ssh -A -t jumphost "$@"
    fi
}

function jumphost() {
    if [ "$#" -eq 0 ]; then
        ssh jumphost
        return
    fi
    HOST=$(echo ${1} | cut -d \@ -f 2)
    if [[ $HOST == *"wifi"* ]] || [[ $HOST == *"aruba"* ]]; then
        tmux_jumphost ssh "admin@${HOST}"
        return
    fi
    tmux_pons ssh $1
    if [ "$?" -ne 0 ]; then
        tmux_jumphost telnet $1
        return
    fi
    return
}

function oui() {
    OUIDB='/var/lib/ieee-data/oui.txt'
    MAC=$(echo $1 | awk '{print tolower($0)}' | sed 's/[^A-Za-z0-9]//g')
    OUI=${MAC::6}
    VENDOR=$(grep -i "$OUI" $OUIDB | awk '{$1=$2=$3=""; print $0}')
    echo $VENDOR
    return
}
