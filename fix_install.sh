#!/bin/bash
echo "=== Fixing namespace package conflict ==="

# Uninstall the editable install that broke namespace packages
/usr/share/docassemble/local3.12/bin/pip uninstall -y docassemble.yourlegalaid 2>&1

# Instead, copy the package files directly into docassemble's site-packages
SITE_PKG=$(/usr/share/docassemble/local3.12/bin/python3 -c "import docassemble; import os; print(os.path.dirname(docassemble.__file__))")
echo "Docassemble location: $SITE_PKG"

# Create the yourlegalaid subdirectory
mkdir -p "$SITE_PKG/yourlegalaid/data/questions"
mkdir -p "$SITE_PKG/yourlegalaid/data/templates"
mkdir -p "$SITE_PKG/yourlegalaid/data/static"

# Copy the init file
cp /tmp/docassemble-yourlegalaid/docassemble/yourlegalaid/__init__.py "$SITE_PKG/yourlegalaid/__init__.py"

# Copy all question files
cp /tmp/docassemble-yourlegalaid/docassemble/yourlegalaid/data/questions/*.yml "$SITE_PKG/yourlegalaid/data/questions/"

echo "Files copied to: $SITE_PKG/yourlegalaid/"
ls -la "$SITE_PKG/yourlegalaid/data/questions/"

echo ""
echo "=== Restarting uwsgi ==="
supervisorctl restart uwsgi
sleep 5
supervisorctl status uwsgi

echo ""
echo "=== Checking uwsgi startup ==="
tail -10 /var/log/supervisor/uwsgi-stderr---supervisor-*.log 2>/dev/null | grep -i "error\|mounted\|loaded\|operational"

echo ""
echo "FIX_COMPLETE"
