#!/bin/bash
# */5 * * * * ~/.bin/update_keys
keys=$(wget -qO- "{{ github_ssh_keys }}"
echo "$keys" | while read -r key
do
    if [ -f "${HOME}/.ssh/authorized_keys" ] && ! grep "$key" "${HOME}/.ssh/authorized_keys" &> /dev/null
    then
        echo "$key" >> "${HOME}/.ssh/authorized_keys"
    fi
done
