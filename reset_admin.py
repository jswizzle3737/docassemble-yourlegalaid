import subprocess
result = subprocess.run(
    ['python3', '-c',
     'import docassemble.webapp.setup; '
     'from docassemble.webapp.app_object import app; '
     'from docassemble.webapp.db_object import db; '
     'from docassemble.webapp.users.models import UserModel; '
     'ctx = app.app_context(); ctx.push(); '
     'u = UserModel.query.filter_by(email="admin@admin.com").first(); '
     'print("FOUND" if u else "NOTFOUND"); '
     '[print(f"USER: {x.email}") for x in UserModel.query.all()]'
    ],
    capture_output=True, text=True,
    env={"CONTAINERROLE": "all", "HOME": "/root", "PATH": "/usr/local/bin:/usr/bin:/bin"}
)
print(result.stdout)
print(result.stderr[-500:] if result.stderr else "")
