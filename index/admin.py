from django.contrib import admin

from .models import Actualite, Debat, Evenement,Chronique,Live,Interview, Musique, VideoDivers,Publicite


from django.contrib import admin
from django.contrib.admin import AdminSite
from .models import Actualite, Publicite, Evenement, Chronique

# Personnalisation de l’en-tête et des titres
admin.site.site_header = "Soninkara Admin"
admin.site.site_title = "Soninkara Média"
admin.site.index_title = "Espace d’administration"

# Appliquer le CSS personnalisé
class CustomAdminSite(AdminSite):
    def each_context(self, request):
        context = super().each_context(request)
        context['custom_css'] = 'css/admin_custom.css'
        return context

admin_site = CustomAdminSite(name='custom_admin')

#
# Register your models here.
admin.site.register(Actualite)
admin.site.register(Musique)
admin.site.register(Evenement)
admin.site.register(Interview)
admin.site.register(Chronique)
admin.site.register(Live)
admin.site.register(VideoDivers)
admin.site.register(Publicite)
admin.site.register(Debat)

