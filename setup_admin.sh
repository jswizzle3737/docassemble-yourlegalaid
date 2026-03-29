#!/bin/bash
cd /tmp
export CONTAINERROLE=all
export DA_CONFIG_FILE=/usr/share/docassemble/config/config.yml

# List users using psql directly
su -c "psql -d docassemble -c \"SELECT id, email, active FROM \\\"user\\\";\"" postgres 2>/dev/null

# Try to reset admin password via psql + werkzeug
PWHASH=$(python3 -c "from werkzeug.security import generate_password_hash; print(generate_password_hash('YLA2026secure!'))")
echo "Password hash: $PWHASH"

su -c "psql -d docassemble -c \"UPDATE \\\"user\\\" SET password='$PWHASH' WHERE email='admin@admin.com';\"" postgres 2>/dev/null
echo "ADMIN_PASSWORD_RESET_DONE"
