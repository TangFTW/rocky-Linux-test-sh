#!/usr/bin/env bash
{
    UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)
    AUDIT_RULE_FILE="/etc/audit/rules.d/50-privileged.rules"
    NEW_DATA=()

    # Find partitions and collect audit rules for files with specific permissions
    for PARTITION in $(findmnt -n -l -k -it $(awk '/nodev/ { print $2 }' /proc/filesystems | paste -sd,) | grep -Pv "noexec|nosuid" | awk '{print $1}'); do
        readarray -t DATA < <(
            find "${PARTITION}" -xdev -perm /6000 -type f | awk -v UID_MIN=${UID_MIN} '{
                print "-a always,exit -F path=" $1 " -F perm=x -F auid>=" UID_MIN " -F auid!=unset -k privileged"
            }'
        )

        for ENTRY in "${DATA[@]}"; do
            NEW_DATA+=("${ENTRY}")
        done
    done

    # Read existing audit rules and combine with new rules
    readarray -t OLD_DATA < "${AUDIT_RULE_FILE}" 2> /dev/null
    COMBINED_DATA=( "${OLD_DATA[@]}" "${NEW_DATA[@]}" )

    # Sort and write unique rules back to the audit rules file
    printf '%s\n' "${COMBINED_DATA[@]}" | sort -u > "${AUDIT_RULE_FILE}"
}