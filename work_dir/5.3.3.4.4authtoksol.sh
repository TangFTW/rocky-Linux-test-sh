#!/usr/bin/env bash
#!/usr/bin/env bash

l_pam_profile="$(head -1 /etc/authselect/authselect.conf)"

if grep -q '^custom/' <<< "$l_pam_profile"; then
    l_pam_profile_path="/etc/authselect/$l_pam_profile"
else
    l_pam_profile_path="/usr/share/authselect/default/$l_pam_profile"
fi

for l_authselect_file in "$l_pam_profile_path"/password-auth "$l_pam_profile_path"/system-auth; do
    if grep -q '^\s*password\s\+\(requisite\|required\|sufficient\)\s\+pam_unix\.so.*use_authtok' "$l_authselect_file"; then
        echo "- \"use_authtok\" is already set in $l_authselect_file"
    else
        echo "- \"use_authtok\" not found in $l_authselect_file. Updating template."
        sed -ri 's/(^\s*password\s+(requisite|required|sufficient)\s+pam_unix\.so\s+.*)$/& use_authtok/' "$l_authselect_file"
    fi
done

echo "Applying authselect changes..."
authselect apply-changes
