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
        'DIRS': [],  # Tu peux ajouter des dossiers ici
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
STATIC_URL = '/staticfiles/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')

# Pour que WhiteNoise gère les fichiers en production
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'


# 🔑 Clé primaire par défaut
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# ⚙️ Django REST Framework config
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',
    ],
}

# 📦 Configuration du stockage Tebi.io (compatible S3)
DEFAULT_FILE_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'  # Utilise S3 comme stockage principal
AWS_ACCESS_KEY_ID = config('AWS_ACCESS_KEY_ID')  # Clé publique Tebi
AWS_SECRET_ACCESS_KEY = config('AWS_SECRET_ACCESS_KEY')  # Clé secrète Tebi
AWS_STORAGE_BUCKET_NAME = config('AWS_STORAGE_BUCKET_NAME')  # Nom du bucket Tebi (ex: soninkara-media)
AWS_S3_ENDPOINT_URL = 'https://s3.tebi.io'  # URL du endpoint S3 chez Tebi
# Organisation des fichiers dans le bucket
AWS_S3_OBJECT_PARAMETERS = {
    'CacheControl': 'max-age=86400',  # Cache pour 1 jour
}

# Optionnel: préfixe de dossier dans le bucket
AWS_LOCATION = 'media'  # Tous les fichiers seront dans le dossier 'media' du bucket
AWS_S3_FILE_OVERWRITE = False  # Ne pas écraser les fichiers avec le même nom
AWS_DEFAULT_ACL = None
AWS_QUERYSTRING_AUTH = False  # (Optionnel : désactive les tokens dans l'URL)