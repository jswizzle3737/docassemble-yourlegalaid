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
                field_type = str(field_obj.get('/FT', 'unknown'))
                options = None
                if '/Opt' in field_obj:
                    options = [str(o) for o in field_obj['/Opt']]
                fields[field_name] = {
                    'type': field_type,
                    'options': options
                }
        all_fields[form_name] = fields
        print(f"{form_name}: {len(fields)} fields found")
        for fn in sorted(fields.keys()):
            ft = fields[fn]['type']
            print(f"  - {fn} ({ft})")
    except Exception as e:
        print(f"{form_name}: ERROR - {e}")
    print()

with open("/tmp/ltb-forms/field_mappings.json", "w") as f:
    json.dump(all_fields, f, indent=2)

print("Field mappings saved to /tmp/ltb-forms/field_mappings.json")
