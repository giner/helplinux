#!/bin/bash

# Get the target (input or output) from the filename and exit otherwise
IFS=''
grep_index="egrep '^[*\ ]*index:\ +[[:digit:]]+$' | egrep -o '[[:digit:]]+'"
if [[ "$0" =~ -output[-[:digit:]]*.sh$ ]]; then
    pacmd_set_default_command="pacmd set-default-sink"
    pacmd_index_1="$(pacmd list-sink-inputs | eval $grep_index)"
    pacmd_index_2="$(pacmd list-sinks | eval $grep_index)"
    pacmd_move_command="pacmd move-sink-input"
    pacmd_list_data=$(pacmd list-sinks)
    message_base="Audio output:"
elif [[ "$0" =~ -input[-[:digit:]]*.sh$ ]]; then
    pacmd_set_default_command="pacmd set-default-source"
    pacmd_index_1="$(pacmd list-source-outputs | eval $grep_index)"
    pacmd_index_2="$(pacmd list-sources | eval $grep_index)"
    pacmd_move_command="pacmd move-source-output"
    pacmd_list_data=$(pacmd list-sources)
    message_base="Audio input:"
else
    exit 1
fi

# Do not supress tabs while read a line
IFS=$' \n'

# Parse pacmd output
# Usage: get_pacmd_section index l2_section l3_section
get_pacmd_section () {
    l1_section=$1
    l2_section=$2
    l3_section=$3
    is_l1_section=false
    is_l2_section=false; [[ -z $l2_section ]] && is_l2_section=true
    is_l3_section=false; [[ -z $l3_section ]] && is_l3_section=true
    echo "$pacmd_list_data" | while read line; do
        if [[ "$line" =~ ^[*\ ]*index:\ +([[:digit:]]+) ]]; then
            # Check index matching
            if [[ ${BASH_REMATCH[1]} == $l1_section ]]; then
                is_l1_section=true
            else
                is_l1_section=false
            fi
        fi
        if [[ -n $l2_section ]] && [[ "$line" =~ ^$'\t'{1}([[:alpha:] -]+): ]]; then
            # Check l2_section matching
            if  [[ ${BASH_REMATCH[1]} == $l2_section ]]; then
                is_l2_section=true
            else
                is_l2_section=false
            fi
        fi
        if [[ -n $l3_section ]] && [[ "$line" =~ ^$'\t'{2}([[:alpha:] -]+): ]]; then
            # Check l3_section matching
            if  [[ ${BASH_REMATCH[1]} == $l3_section ]]; then
                is_l3_section=true
            else
                is_l3_section=false
            fi
        fi
        if $is_l1_section && $is_l2_section && $is_l3_section; then
            echo $line
        fi
done
}

# Get the output ID from the filename if available and cycle otherwise
if [[ "$0" =~ -([[:digit:]]+)\.sh$ ]]; then
    id=${BASH_REMATCH[1]}
else
    # Get the current target ID from pacmd output
    default=$(echo "$pacmd_list_data" | egrep '^ *\* *index:')
    [[ "$default" =~ ^\ *\*\ *index:\ +([[:digit:]]+) ]] || exit 1
    default_id="${BASH_REMATCH[1]}"
    # Get the list of targets
    list=($pacmd_index_2)
    # Exclude targets without ports from the list
    for ((x=0, max=${#list[@]}; x<$max; x++)); do
        if [[ -z $(get_pacmd_section ${list[$x]} ports) ]]; then
            unset list[$x]
        fi
    done
    # Reasseble array to get rid of empty values after "unset"
    list=($(echo ${list[@]}))
    # Get the next target ID (cycle)
    list=(${list[@]} ${list[0]})
    for ((x=0, id=${list[0]}, max=${#list[@]}-1; x<$max; x++)); do
        if [[ ${list[$x]} == $default_id ]]; then
            id=${list[$x+1]}
            break
        fi
    done
fi

# Set this target as a default and move running applications to it
$pacmd_set_default_command $id > /dev/null
for index in $pacmd_index_1; do
    $pacmd_move_command $index $id > /dev/null;
done

# Display the name of selected audio card with notify-send
get_pacmd_section $id properties | while read line; do
    if [[ "$line" =~ ^$'\t'{2}alsa.card_name\ =\ \"(.*)\" ]]; then
        alsa_card_name=${BASH_REMATCH[1]}
        message="$message_base $id - $alsa_card_name"
        echo $message
        notify-send --icon=audio-card --expire-time=2000 "$message"
    fi
done
