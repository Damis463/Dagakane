from pathlib import Path
import os
from decouple import config, Csv
import dj_database_url

# 📁 Chemin de base du projet
BASE_DIR = Path(__file__).resolve().parent.parent

# 🔐 Clé secrète (utilise .env ou Render env vars)
SECRET_KEY = config("DJANGO_SECRET_KEY")

# 🐞 Mode debug
DEBUG = config("DEBUG", cast=bool, default=False)

# 🌍 Hôtes autorisés (utilise CSV pour support Render)
ALLOWED_HOSTS = config("ALLOWED_HOSTS", cast=Csv(), default="*")

# 🌐 Autoriser toutes les origines (Flutter, navigateur...)
CORS_ALLOW_ALL_ORIGINS = True

# 📦 Applications Django
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # 🔌 Extensions
    'rest_framework',
    'corsheaders',

    # 📁 Tes apps personnalisées
    'index',
    'api',
    
    # 📦 Stockage distant (Tebi.io via S3 protocol)
    'storages',
]

# ⚙️ Middleware
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',  # Pour fichiers statiques sur Render
    'corsheaders.middleware.CorsMiddleware',       # Pour Flutter/API
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# 🔗 Fichier URLs principal
ROOT_URLCONF = 'soninkara_app.urls'

# 🧩 Templates HTML
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

# 🚀 WSGI
WSGI_APPLICATION = 'soninkara_app.wsgi.application'

# 🗄️ Base de données via dj-database-url
DATABASES = {
    'default': dj_database_url.config(
        default=config("DATABASE_URL")
    )
}

# 🔐 Validation des mots de passe
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# 🗣️ Langue et fuseau horaire
LANGUAGE_CODE = 'fr'
TIME_ZONE = 'Africa/Bamako'
USE_I18N = True
USE_TZ = True

# 📁 Fichiers statiques (CSS, JS, etc.)
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# 🔑 Clé primaire par défaut
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# ⚙️ Django REST Framework config
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',
    ],
}

# ====================== CONFIGURATION TEBIO.IO ======================
# Activation du stockage S3 pour les médias
DEFAULT_FILE_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'

# Configuration d'accès à Tebi.io
AWS_ACCESS_KEY_ID = config('TEBIO_ACCESS_KEY')  # Clé d'accès Tebi
AWS_SECRET_ACCESS_KEY = config('TEBIO_SECRET_KEY')  # Clé secrète Tebi
AWS_STORAGE_BUCKET_NAME = config('TEBIO_BUCKET_NAME')  # Nom du bucket
AWS_S3_ENDPOINT_URL = 'https://s3.tebi.io'  # Endpoint Tebi

# Paramètres optimisés pour Tebi.io
AWS_S3_OBJECT_PARAMETERS = {
    'CacheControl': 'max-age=86400',  # Cache de 1 jour
    'ACL': 'public-read'  # Définit les permissions de lecture publique
}

AWS_LOCATION = 'media'  # Dossier de stockage dans le bucket
AWS_S3_FILE_OVERWRITE = False  # Empêche l'écrasement des fichiers
AWS_DEFAULT_ACL = 'public-read'  # Permissions par défaut
AWS_QUERYSTRING_AUTH = False  # URLs publiques sans signature
AWS_S3_REGION_NAME = 'eu-central-1'  # Région par défaut pour Tebi

# Désactive le stockage local des médias en production
if not DEBUG:
    MEDIA_URL = f'https://{TEBIO_BUCKET_NAME}.s3.tebi.io/{AWS_LOCATION}/'
else:
    # En mode développement, on peut utiliser le stockage local
    MEDIA_URL = '/media/'
    MEDIA_ROOT = os.path.join(BASE_DIR, 'media')