#!/bin/bash
BASE="https://tribunalsontario.ca/documents/ltb"
DEST="/tmp/ltb-forms"
mkdir -p "$DEST"

echo "=== Downloading Official LTB PDF Forms ==="

# Notices
for form in N4 N5 N7 N8 N12 N13; do
  URL="$BASE/Notices%20of%20Termination%20%26%20Instructions/${form}.pdf"
  echo "Downloading $form..."
  curl -sL -o "$DEST/${form}.pdf" "$URL"
  echo "  -> $(stat -c%s "$DEST/${form}.pdf" 2>/dev/null || echo 'FAILED') bytes"
done

# Tenant Applications
for form in T1 T2 T6; do
  URL="$BASE/Tenant%20Applications%20%26%20Instructions/${form}.pdf"
  echo "Downloading $form..."
  curl -sL -o "$DEST/${form}.pdf" "$URL"
  echo "  -> $(stat -c%s "$DEST/${form}.pdf" 2>/dev/null || echo 'FAILED') bytes"
done

# Landlord Applications
for form in L1 L2; do
  URL="$BASE/Landlord%20Applications%20%26%20Instructions/${form}.pdf"
  echo "Downloading $form..."
  curl -sL -o "$DEST/${form}.pdf" "$URL"
  echo "  -> $(stat -c%s "$DEST/${form}.pdf" 2>/dev/null || echo 'FAILED') bytes"
done

echo ""
echo "=== All downloads complete ==="
ls -la "$DEST/"
echo ""

# Extract field names from each PDF
echo "=== Extracting PDF form fields ==="
pip install PyPDF2 2>/dev/null | tail -1

python3 << 'PYEOF'
import os, json
from PyPDF2 import PdfReader

dest = "/tmp/ltb-forms"
all_fields = {}

for fname in sorted(os.listdir(dest)):
    if not fname.endswith('.pdf'):
        continue
    form_name = fname.replace('.pdf', '')
    filepath = os.path.join(dest, fname)
    try:
        reader = PdfReader(filepath)
        fields = {}
        if reader.get_fields():
            for field_name, field_obj in reader.get_fields().items():
                field_type = field_obj.get('/FT', 'unknown')
                fields[field_name] = str(field_type)
        all_fields[form_name] = fields
        print(f"{form_name}: {len(fields)} fields found")
    except Exception as e:
        print(f"{form_name}: ERROR - {e}")

# Save field mappings
with open("/tmp/ltb-forms/field_mappings.json", "w") as f:
    json.dump(all_fields, f, indent=2)

print("\nField mappings saved to /tmp/ltb-forms/field_mappings.json")
PYEOF
