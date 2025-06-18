from django.contrib import admin
from django.contrib.admin import ModelAdmin

from .models import Actualite, Debat, Evenement,Chronique,Live,Interview, Musique, VideoDivers,Publicite
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


