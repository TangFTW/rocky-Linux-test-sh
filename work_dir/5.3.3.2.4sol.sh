#!/usr/bin/env bash

# Location of your custom PAM profile
AUTHSELECT_DIR="/etc/authselect/$(head -1 /etc/authselect/authselect.conf | grep 'custom/')"

# Step 1: Remove any "maxrepeat" options from pam_pwquality.so lines in PAM configs
for l_pam_file in system-auth password-auth; do
    sed -ri 's/(^\s*password\s+(requisite|required|sufficient)\s+pam_pwquality\.so.*)(\s+maxrepeat\s*=\s*\S+)(.*$)/\1\3/' \
        "$AUTHSELECT_DIR/$l_pam_file"
done

# Step 2: Create pwquality drop-in config for maxrepeat
cat > /etc/security/pwquality.conf.d/50-pwrepeat.conf << 'EOF'
# CIS control: limit maxrepeat
maxrepeat = 3
EOF

# Step 3: Apply PAM changes
authselect apply-changes
