# AGENTS.md — docassemble-yourlegalaid

This file is read by AI coding agents (Antigravity, Jules) working in this repo.
Follow every rule here before touching any file.

## Project Overview

`docassemble-yourlegalaid` is a Docassemble package that powers guided legal
interviews at **https://interviews.yourlegalaid.ca**. Each interview maps to a
Landlord and Tenant Board (Ontario) form, walks the user through the required
fields, and produces a court-ready PDF via a DOCX Jinja2 template.

The public-facing landing pages live on **yourlegalaid.ca** (WordPress) and link
directly to each interview URL:
`/interview?i=docassemble.yourlegalaid:data/questions/{form}_interview.yml`

## Repo Structure

```
docassemble-yourlegalaid/          ← Python package root
  setup.py
  docassemble/
    yourlegalaid/
      data/
        questions/                 ← Docassemble YAML interview files
          shared_fields.yml        ← Shared questions included by every interview
          n4_interview.yml
          l1_interview.yml
          ...
        templates/                 ← DOCX Jinja2 templates (one per form)
          n4_template.docx
          l1_template.docx
          ...
        static/                    ← Logo, CSS overrides
docker-compose.yml                 ← Local Docassemble dev server
.github/
  workflows/
    jules.yml                      ← Jules AI coding agent trigger
    test.yml                       ← ALKiln test runner
  ISSUE_TEMPLATE/
    new-ltb-form.yml
    fix-interview.yml
```

## Forms in Scope

| Code | Full Name                              | Type     | Fee  |
|------|----------------------------------------|----------|------|
| N4   | Notice to End Tenancy – Non-Payment    | Notice   | $49  |
| N5   | Notice – Damage/Interference           | Notice   | $49  |
| N7   | Notice – Danger to Safety              | Notice   | $49  |
| N8   | Notice – Persistent Late Rent          | Notice   | $49  |
| N12  | Notice – Landlord Personal Use         | Notice   | $49  |
| N13  | Notice – Demolition/Renovation         | Notice   | $49  |
| L1   | Application to Evict + Collect Rent    | Application | $49 |
| L2   | Application to End Tenancy             | Application | $49 |
| T1   | Tenant – Rebate Application            | Application | $53 |
| T2   | Tenant – Rights Application            | Application | $53 |
| T6   | Tenant – Maintenance Application       | Application | $53 |
| CS   | Consent and Settlement Order           | Settlement | $49 |

## Interview Architecture Rules

### shared_fields.yml
Every interview MUST start with:
```yaml
---
include:
  - shared_fields.yml
---
```
`shared_fields.yml` defines: `tenant`, `landlord`, `rental_unit` objects,
`disclaimer_template`, address blocks, and the `DAList` pattern for repeated items.
Never redefine these in individual interviews.

### Mandatory Block Pattern
The mandatory block must reference every variable the interview collects,
in the order screens should appear. Use conditional logic for optional branches:

```yaml
mandatory: True
code: |
  intro_screen_seen
  landlord.name.first
  landlord.address
  tenant.name.first
  rental_unit.address
  # ... all fields in order
  review_complete
  download_screen
```

### Naming Conventions
- Objects: `landlord`, `tenant`, `rental_unit`, `applicant`, `respondent`
- Name fields: `landlord.name.first`, `landlord.name.last`
- Address: always use `landlord.address` (string field), `landlord.city`, `landlord.postal_code`
- Dates: always `datatype: date`
- Currency: always `datatype: currency`
- Lists: use `DAList.using(object_type=DAObject)` with `there_are_any`/`there_is_another`

### Final Screen
Every interview ends with a question block that is NOT mandatory itself but is
triggered from the mandatory code block. It shows the download button:

```yaml
event: download_screen
question: |
  ## Your [FORM] is Ready
buttons:
  - Download PDF: exit
    url: https://yourlegalaid.ca/thank-you/
  - Start Another Form: restart
```

## DOCX Template Rules

Templates live in `data/templates/` as `{form}_template.docx`.
They use Docassemble's Jinja2 dialect:
- Variables: `{{ landlord.name }}`, `{{ termination_date }}`
- Loops: `{%p for p in rent_periods %}` ... `{%p endfor %}`
- Conditionals: `{%p if n4_served %}` ... `{%p endif %}`
- Use `{%tr ... %}` for table rows, `{%p ... %}` for paragraphs

Each template must mirror the official Tribunals Ontario form layout exactly.
Download the official PDF from tribunalsontario.ca/ltb/ as reference.

## Adding a New Form — Checklist

When asked to add a new LTB form:
1. Read the official PDF (attached in the GitHub issue or in `data/static/pdfs/`)
2. Extract every field name exactly as it appears on the form
3. Create `data/questions/{form}_interview.yml` following the patterns above
4. Add the form to `shared_fields.yml` if it introduces reusable field objects
5. Create `data/templates/{form}_template.docx` matching the official layout
6. Add an entry to `setup.py` `install_requires` if new dependencies are needed
7. Write an ALKiln test in `tests/{form}_test.feature`
8. Update `README.md` with the new form

## Local Dev Server

```bash
# Start local Docassemble (Docker required)
docker compose up -d

# Access at http://localhost (first run takes ~5 min)
# Admin: admin@admin.com / admin (change after first login)

# Install the package in dev mode
docker exec -it $(docker compose ps -q docassemble) \
  pip install -e /tmp/docassemble-yourlegalaid
```

## Testing

ALKiln tests live in `tests/`. Run them against the local server:
```bash
npx @alkiln/alkiln-core@latest \
  --tags @{form} \
  --base-url http://localhost
```

## What NOT to Do
- Never hardcode dollar amounts or dates in templates — always use variables
- Never skip the `shared_fields.yml` include
- Never use `mandatory: True` on the download screen (use `event:` instead)
- Never commit DOCX templates without testing variable substitution end-to-end
- Never modify `shared_fields.yml` without checking all 12 interviews still work
