from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.http import JsonResponse
from django.shortcuts import redirec
def home(request):
    return JsonResponse({"message": "Bienvenue sur l'API Soninkara Média !"})


urlpatterns = [
    # Interface d'administration Django
    path('admin/', admin.site.urls),

    # Routes de l'application principale
    path('', include('index.urls')),

    # Inclusion des routes API (qui contiennent le router)
    path('api/', include('api.urls')),
]

# Gestion des fichiers médias en développement
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
