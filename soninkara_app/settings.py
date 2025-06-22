from pathlib import Path
import os
from decouple import config, Csv
import dj_database_url

# 📁 Base du projet
BASE_DIR = Path(__file__).resolve().parent.parent

# 🔐 Secret key & debug
SECRET_KEY = config("DJANGO_SECRET_KEY")
DEBUG = config("DEBUG", cast=bool, default=False)

# 🌍 Hôtes autorisés
ALLOWED_HOSTS = config("ALLOWED_HOSTS", cast=Csv(), default="*")

# 🌐 CORS
CORS_ALLOW_ALL_ORIGINS = True

# 📦 Apps installées
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    'rest_framework',
    'corsheaders',
    'storages',

    'index',
    'api',
]

# ⚙️ Middleware
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# 🔗 URLs
ROOT_URLCONF = 'soninkara_app.urls'

# 🧩 Templates
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

# 🗄️ Base de données
DATABASES = {
    'default': dj_database_url.config(default=config("DATABASE_URL"))
}

# 🔐 Password validation
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# 🌍 Langue et fuseau horaire
LANGUAGE_CODE = 'fr'
TIME_ZONE = 'Africa/Bamako'
USE_I18N = True
USE_TZ = True

# 📁 Fichiers statiques
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# 🔑 Champ ID auto par défaut
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# ⚙️ Django REST
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',
    ],
}

# =================== TEBI STORAGE ====================

USE_TEBI = config('USE_TEBI', cast=bool, default=True)

if USE_TEBI:
    # 🔐 Clés via .env
    AWS_ACCESS_KEY_ID = config('AWS_ACCESS_KEY_ID')
    AWS_SECRET_ACCESS_KEY = config('AWS_SECRET_ACCESS_KEY')
    AWS_STORAGE_BUCKET_NAME = config('AWS_STORAGE_BUCKET_NAME')

    # 🌐 Endpoint Tebi
    AWS_S3_ENDPOINT_URL = 'https://s3.tebi.io'

    # ⚙️ Paramètres recommandés
    AWS_S3_OBJECT_PARAMETERS = {
        'CacheControl': 'max-age=86400',
    }
    AWS_DEFAULT_ACL = None
    AWS_QUERYSTRING_AUTH = False
    AWS_S3_FILE_OVERWRITE = False

    # 📦 Stockage Tebi
    DEFAULT_FILE_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'

    # 📁 URL publique des fichiers médias sur Tebi
    MEDIA_URL = f'https://{AWS_STORAGE_BUCKET_NAME}.s3.tebi.io/'    
else:
    # 📁 Fichiers médias en local (pour dev/localhost)
    MEDIA_URL = '/media/'
    MEDIA_ROOT = os.path.join(BASE_DIR, 'media')
