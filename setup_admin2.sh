#!/bin/bash
export DA_CONFIG_FILE=/usr/share/docassemble/config/config.yml

# Generate password hash using docassemble's Python environment
PWHASH=$(/usr/share/docassemble/local3.12/bin/python3 -c "from werkzeug.security import generate_password_hash; print(generate_password_hash('YLA2026secure!'))")
echo "Hash generated: ${PWHASH:0:20}..."

# Update the admin user password
su -c "psql -d docassemble -c \"UPDATE \\\"user\\\" SET password='$PWHASH' WHERE email='admin@example.com';\"" postgres

# Also create an API key for the admin
APIKEY="YLA_$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
echo "API_KEY=$APIKEY"

su -c "psql -d docassemble -c \"INSERT INTO api (user_id, api_key, security, name, constraints) VALUES (1, '$APIKEY', 'admin', 'YourLegalAid Setup', '{}') ON CONFLICT DO NOTHING;\"" postgres 2>/dev/null || echo "API table may not exist yet"

echo "SETUP_COMPLETE"
