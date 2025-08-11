#!/usr/bin/env bash

for l_pam_file in system-auth password-auth; do
    # Get the custom profile path
    l_profile_path=$(head -1 /etc/authselect/authselect.conf | grep 'custom/')
    l_file="/etc/authselect/${l_profile_path}/${l_pam_file}"

    # Remove the 'nullok' option from pam_unix.so lines
    sed -ri 's/(^\s*password\s+(requisite|required|sufficient)\s+pam_unix\.so\s+.*)(nullok)(\s*.*)$/\1\3/g' "$l_file"
done
