# create_superuser.py
import os
import django

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "soninkara_app.settings")
django.setup()

from django.contrib.auth import get_user_model

User = get_user_model()

if not User.objects.filter(username="admin").exists():
    User.objects.create_superuser("admin", "adamatraore463@gmail.com", "Fatoumata63")
    print("✅ Superutilisateur créé avec succès.")
else:
    print("ℹ️ Superutilisateur existe déjà.")
