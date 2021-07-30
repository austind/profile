function jump() {
    command sshpass -e ssh -A -t jumphost "$@"
}

function tmux_jump() {
    # Open SSH through tmux
    if [ -n "$TMUX" ]; then
        tmux rename-window "$(echo $2)"
        jump "$@"
        tmux set-window-option automatic-rename "on" 1>/dev/null
    else
        jump "$@"
    fi
}

function auth() {
    read -sp 'Cisco password: ' pass
    export SSHPASS=$pass
}

function deauth() {
    export SSHPASS=''
}

function jh() {
    # SSH to device without keyboard interactive password, through jumphost
    # calling `jumphost` with no arguments connects to jumphost directly
    if [ "$#" -eq 0 ]; then
        ssh jumphost
    fi
    if [ -z "$SSHPASS" ]; then
        auth
    fi
    tmux_jump sshpass -e ssh $1
}

function clearkey() {
    # Clear SSH ID from known_hosts
    DOMAIN='example.net'
    ssh jumphost ssh-keygen -R $1
    IPADDRESS=$(dig $1.$DOMAIN. a +short | grep -v '^[^0-9\.].*$')
    if [ -n "$IPADDRESS" ]; then
        ssh jumphost ssh-keygen -R $IPADDRESS
    fi
}

function oui() {
    # Look up vendor of MAC OUI
    OUIDB='/var/lib/ieee-data/oui.txt'
    MAC=$(echo $1 | awk '{print tolower($0)}' | sed 's/[^A-Za-z0-9]//g')
    OUI=${MAC::6}
    VENDOR=$(grep -i "$OUI" $OUIDB | awk '{$1=$2=$3=""; print $0}')
    echo $VENDOR
}

# Custom shell prompt
export PS1='\[\e]0;\w\a\]\n\[\e[32m\]\u@\h [$?]: \[\e[33m\]\w\[\e[0m\]\n\$ '
if [ -z "$TMUX" ]; then
    tmux
fi
