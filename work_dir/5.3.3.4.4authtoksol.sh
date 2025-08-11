#!/usr/bin/env bash
{
    l_pam_profile="$(head -1 /etc/authselect/authselect.conf)"

    if grep -Pq -- '^custom\/' <<< "$l_pam_profile"; then
        l_pam_profile_path="/etc/authselect/$l_pam_profile"
    else
        l_pam_profile_path="/usr/share/authselect/default/$l_pam_profile"
    fi

    for l_authselect_file in "$l_pam_profile_path"/password-auth "$l_pam_profile_path"/system-auth; do
        if grep -Pq '^\h*password\h+([^#\n\r]+)\h+pam_unix\.so\h+([^#\n\r]+\h+)?use_authtok\b' "$l_authselect_file"; then
            echo "- \"use_authtok\" is already set"
        else
            echo "- \"use_authtok\" is not set. Updating template"
            sed -ri 's/(^\s*password\s+(requisite|required|sufficient)\s+pam_unix\.so\s+.*)$/& use_authtok/g' "$l_authselect_file"
        fi
    done
}