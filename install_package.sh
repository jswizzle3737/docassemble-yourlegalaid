#!/bin/bash
echo "=== Installing docassemble.yourlegalaid package ==="

# Install the package using docassemble's Python
cd /tmp/docassemble-yourlegalaid
/usr/share/docassemble/local3.12/bin/pip install -e . 2>&1 | tail -5

echo ""
echo "=== Verifying installation ==="
/usr/share/docassemble/local3.12/bin/python3 -c "import docassemble.yourlegalaid; print('PACKAGE_INSTALLED_OK')"

echo ""
echo "=== Listing interview files ==="
ls -la /tmp/docassemble-yourlegalaid/docassemble/yourlegalaid/data/questions/

echo ""
echo "=== Restarting uwsgi ==="
supervisorctl restart uwsgi
sleep 3
supervisorctl status uwsgi

echo ""
echo "INSTALL_COMPLETE"
