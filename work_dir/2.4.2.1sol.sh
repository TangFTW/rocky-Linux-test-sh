#!/usr/bin/env bash
{
    grep -Pq -- '^daemon\b' /etc/group && l_group="daemon" || l_group="root"

    # Ensure at.allow exists and set permissions
    [ ! -e "/etc/at.allow" ] && touch /etc/at.allow
    chown root:"$l_group" /etc/at.allow
    chmod u-x,g-wx,o-rwx /etc/at.allow

    # Set permissions for at.deny if it exists
    if [ -e "/etc/at.deny" ]; then
        chown root:"$l_group" /etc/at.deny
        chmod u-x,g-wx,o-rwx /etc/at.deny
    fi
}