#!/usr/bin/env bash
# Audit: Ensure local interactive user home directories are configured (CIS 7.2.8)

l_valid_shells="^($( awk -F\/ '$NF != "nologin" {print}' /etc/shells \
  | sed -rn '/^\//{s,/,\\\\/,g;p}' | paste -s -d '|' - ))$"

unset a_uarr && a_uarr=()

# Collect interactive users + home directories
while read -r l_user l_home; do
  a_uarr+=("$l_user $l_home")
done <<< "$(awk -v pat="$l_valid_shells" -F: \
  '$(NF) ~ pat { print $1 " " $(NF-1) }' /etc/passwd)"

l_output="" l_output2=""
l_mask='0027'
l_max="$( printf '%o' $(( 0777 & ~$l_mask)) )"

# Check each user home
for entry in "${a_uarr[@]}"; do
  l_user=$(awk '{print $1}' <<< "$entry")
  l_home=$(awk '{print $2}' <<< "$entry")

  if [ -d "$l_home" ]; then
    read -r l_owner l_mode <<< "$(stat -Lc '%U %#a' "$l_home")"

    # Ownership check
    [ "$l_user" != "$l_owner" ] && \
      l_output2="$l_output2\n - User: \"$l_user\" home \"$l_home\" is owned by \"$l_owner\""

    # Permission check
    if [ $(( l_mode & l_mask )) -gt 0 ]; then
      l_output2="$l_output2\n - User: \"$l_user\" home \"$l_home\" has mode \"$l_mode\", should be \"$l_max\" or more restrictive"
    fi
  else
    l_output2="$l_output2\n - User: \"$l_user\" home \"$l_home\" does not exist"
  fi
done

# Final output
if [ -z "$l_output2" ]; then
  echo -e "\n- Audit Result:\n ** PASS **\n - All interactive user home directories are correctly configured"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Issues found:\n$l_output2"
fi
