#!/bin/bash
echo "=== UWSGI LOG ==="
find /var/log/supervisor -name "uwsgi-stderr*" -exec tail -50 {} \;

echo ""
echo "=== DOCASSEMBLE LOG ==="
find /usr/share/docassemble/log -name "*.log" -exec tail -30 {} \;

echo ""
echo "=== NGINX ERROR LOG ==="
tail -20 /var/log/nginx/error.log 2>/dev/null

echo ""
echo "=== TEST IMPORT ==="
/usr/share/docassemble/local3.12/bin/python3 -c "
import yaml
with open('/tmp/docassemble-yourlegalaid/docassemble/yourlegalaid/data/questions/shared_fields.yml') as f:
    docs = list(yaml.safe_load_all(f))
    print(f'shared_fields.yml: {len(docs)} documents parsed OK')
" 2>&1

echo ""
echo "=== TEST N4 IMPORT ==="
/usr/share/docassemble/local3.12/bin/python3 -c "
import yaml
with open('/tmp/docassemble-yourlegalaid/docassemble/yourlegalaid/data/questions/n4_interview.yml') as f:
    docs = list(yaml.safe_load_all(f))
    print(f'n4_interview.yml: {len(docs)} documents parsed OK')
" 2>&1
