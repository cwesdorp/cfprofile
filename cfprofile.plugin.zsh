#!/usr/bin/env zsh

#
# Easy management of different CF profiles for the CF CLI tools
#

if [[ "$SHELL" =~ "zsh" ]]; then
    BLUE_BOLD="%{$fg_bold[blue]%}"
    RED_BOLD="%{$fg_bold[red]%}"
    RESET="%{$reset_color%}"
fi


function cf-profile {
    PROFILE=$1
    if [ -n "$PROFILE" ]; then 
        # Switch profile
        if [[ "$PROFILE" == "default" ]]; then
            unset CF_HOME 
        elif [[ -d ~/.cf/profiles/$PROFILE ]]; then
            export CF_HOME=~/.cf/profiles/$PROFILE
        else
            echo "Invalid profile name $PROFILE" > /dev/stderr
            return 1
        fi

    else
        # Show profile 
        if [[ -n "$CF_HOME"  ]]; then
            echo -n "$(basename $CF_HOME)"
        elif [[ -e ~/.cf/config.json ]]; then
            echo -n "default"
        fi
    fi
}

function _cf-get-profile-target_jq() {
    echo -n $(jq -r ".Target" $1)
}

function cf-profile-get-target {
    PROFILE=$1
    if [[ -n "$PROFILE" && -e ~/.cf/profiles/$PROFILE/.cf/config.json ]]; then
        PROFILE_CONFIG=~/.cf/profiles/$PROFILE/.cf/config.json
    elif [[ -e ~/.cf/config.json ]]; then
        PROFILE_CONFIG=~/.cf/config.json
    else
        return 1
    fi

    if [[ $(where jq > /dev/null; echo $?) -eq 0 ]]; then
        echo -n $(jq -r ".Target" $PROFILE_CONFIG)
    elif [[ $(where pythona > /dev/null; echo $?) -eq 0 ]]; then
        python -c "import json; 
with open('${PROFILE_CONFIG}', 'r') as f:
    config = json.load(f)
    print(config.get('Target'));"
    elif [[ $(where node > /dev/null; echo $?) -eq 0 ]]; then
        node -e "fileConfig = require('fs').readFileSync('$PROFILE_CONFIG')
jsonConfig = JSON.parse(fileConfig)
console.log(jsonConfig.Target)"
    fi
}

function cf-profile-list {
    if [[ -e ~/.cf/config.json ]]; then
        echo "default: $(cf-profile-get-target)"
    fi
   
    for p in $(ls ~/.cf/profiles); do
        echo "$p: $(cf-profile-get-target $p)"
    done

}

function cf-profile-create {
    PROFILE=~/.cf/profiles/$1
    if [[ ! -d $PROFILE ]]; then
        mkdir -p $PROFILE
        export CF_HOME=$PROFILE
        echo "$1 created, use 'cf login' to complete'" 
    fi

    return 1
}


function cf-profile-prompt {
    PROFILE=$(cf-profile)
    [[ -n "$PROFILE" ]] && echo "${BLUE_BOLD}cf:(${RED_BOLD}${PROFILE}${BLUE_BOLD})${RESET}"
}

function cf-profile-target-prompt {
    PROFILE=$(cf-profile)
    TARGET=$(cf-profile-get-target $PROFILE)
    if [[ -n "$TARGET" ]]; then 
        echo "${BLUE_BOLD}cf:(${RED_BOLD}${TARGET}${BLUE_BOLD})${RESET}"
    else
        cf-profile-prompt
    fi
}

