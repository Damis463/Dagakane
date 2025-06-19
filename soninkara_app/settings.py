
from pathlib import Path
import os
from decouple import config, Csv
import dj_database_url
# Chemin de base du projet
BASE_DIR = Path(__file__).resolve().parent.parent

# Clé secrète (change-la pour la production)
SECRET_KEY = config("DJANGO_SECRET_KEY")
DEBUG      = config("DEBUG", cast=bool, default=False)

# Mode debug (Désactive-le en production)


# Autoriser toutes les IPs (Flutter, mobile, navigateur, etc.)
ALLOWED_HOSTS = ['*']

# CORS autorisé pour toutes les origines (Flutter, web, etc.)
CORS_ALLOW_ALL_ORIGINS = True

# Applications installées
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # Ajouts pour API et Flutter
    'rest_framework',
    'corsheaders',         # CORS pour Flutter
    'index',               # Ton app principale
]

# Middleware
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # Doit être en haut
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# Fichier URLs principal
ROOT_URLCONF = 'soninkara_app.urls'

# Templates
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

# WSGI
WSGI_APPLICATION = 'soninkara_app.wsgi.application'

# Base de données
DATABASES = {
    'default': dj_database_url.config(
        default=config("DATABASE_URL")
    )
}
# Validation des mots de passe
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

# Langue et fuseau horaire
LANGUAGE_CODE = 'fr'
TIME_ZONE = 'Africa/Bamako'

USE_I18N = True
USE_TZ = True


# Fichiers médias (images, vidéos uploadées)
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

# Type de clé primaire par défaut
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# Django REST Framework (DRF)
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',
    ],
}
