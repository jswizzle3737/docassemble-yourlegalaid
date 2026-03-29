#!/bin/bash
SITE_PKG=/usr/share/docassemble/local3.12/lib/python3.12/site-packages/docassemble/yourlegalaid

echo "=== Copying updated interview YAMLs ==="
cp /tmp/docassemble-yourlegalaid/docassemble/yourlegalaid/data/questions/*.yml "$SITE_PKG/data/questions/"
echo "Interview files:"
ls -la "$SITE_PKG/data/questions/"

echo ""
echo "=== Verifying PDF templates ==="
ls -la "$SITE_PKG/data/templates/"

echo ""
echo "=== Restarting uwsgi ==="
supervisorctl restart uwsgi
sleep 8
supervisorctl status uwsgi

echo ""
echo "=== Testing interview endpoints ==="
for form in n4 n5 n7 n8 n12 n13 t1 t2 t6 l1 l2; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost/interview?i=docassemble.yourlegalaid:data/questions/${form}_interview.yml")
  echo "${form}_interview.yml: $code"
done

echo ""
echo "DEPLOY_COMPLETE"
