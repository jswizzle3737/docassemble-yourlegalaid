#!/bin/bash
/usr/share/docassemble/local3.12/bin/python3 << 'PYEOF'
from werkzeug.security import generate_password_hash
from sqlalchemy import create_engine, text

pw_hash = generate_password_hash('YLA2026secure!', method='pbkdf2:sha256')
engine = create_engine('postgresql+psycopg2://docassemble:abc123@localhost/docassemble')

with engine.connect() as conn:
    result = conn.execute(text("SELECT id, email, password FROM \"user\" WHERE email='admin@example.com'"))
    row = result.fetchone()
    if row:
        print(f"Found user: {row[1]}")
        conn.execute(text("UPDATE \"user\" SET password=:pw WHERE email='admin@example.com'"), {"pw": pw_hash})
        conn.commit()
        print("PASSWORD_UPDATED_OK")
    else:
        print("USER_NOT_FOUND")
PYEOF
