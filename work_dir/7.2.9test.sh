#!/bin/bash
# Audit user dotfiles

echo "=== Audit: user dotfiles ==="

# Get interactive users (not nologin/false)
awk -F: '($7 !~ /nologin|false/) {print $1 ":" $6}' /etc/passwd | while IFS=: read -r user home; do
    [ ! -d "$home" ] && continue

    echo ""
    echo "User: $user   Home: $home"

    # 1. Look for forbidden files
    for badfile in .forward .rhost; do
        if [ -f "$home/$badfile" ]; then
            echo "  [FAIL] $home/$badfile exists"
        fi
    done

    # 2. Check .netrc
    if [ -f "$home/.netrc" ]; then
        perms=$(stat -c "%a" "$home/.netrc")
        [ "$perms" -gt 600 ] && echo "  [FAIL] .netrc too open ($perms)"
    fi

    # 3. Check .bash_history
    if [ -f "$home/.bash_history" ]; then
        perms=$(stat -c "%a" "$home/.bash_history")
        [ "$perms" -gt 600 ] && echo "  [FAIL] .bash_history too open ($perms)"
    fi

    # 4. Check all other dotfiles
    find "$home" -xdev -type f -name '.*' 2>/dev/null | while read f; do
        perms=$(stat -c "%a %U %G" "$f")
        mode=$(echo "$perms" | awk '{print $1}')
        owner=$(echo "$perms" | awk '{print $2}')
        group=$(echo "$perms" | awk '{print $3}')
        [ "$mode" -gt 644 ] && echo "  [FAIL] $f has mode $mode (should be <=644)"
        [ "$owner" != "$user" ] && echo "  [FAIL] $f owned by $owner (should be $user)"
        [ "$group" != "$(id -gn $user)" ] && echo "  [FAIL] $f group-owned by $group (should be $(id -gn $user))"
    done
done
