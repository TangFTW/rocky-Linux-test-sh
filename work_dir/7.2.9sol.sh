#!/usr/bin/env bash

# Loop through all interactive users
awk -F: '($7 !~ /(nologin|false)/) {print $1 " " $6}' /etc/passwd | while read user home; do
  if [ -d "$home" ]; then
    # Fix ownership
    chown -R "$user":"$user" "$home"/.[!.]* "$home"/..?* 2>/dev/null

    # Fix permissions
    find "$home" -xdev -type f -name '.*' -exec chmod 644 {} \;
    [ -f "$home/.bash_history" ] && chmod 600 "$home/.bash_history"
    [ -f "$home/.netrc" ] && chmod 600 "$home/.netrc"

    # Flag risky files
    [ -f "$home/.forward" ] && echo "Investigate: $home/.forward"
    [ -f "$home/.rhost" ] && echo "Investigate: $home/.rhost"
  fi
done
