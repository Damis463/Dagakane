from django.urls import include, path
from rest_framework.routers import DefaultRouter

# Configuration du router DRF
from .views import (
    ActualiteViewSet, DebatViewSet, EvenementViewSet, InterviewViewSet,
    ChroniqueViewSet, LiveViewSet, PubliciteViewSet, VideoDiversViewSet
)


router = DefaultRouter()
router.register(r'actualites', ActualiteViewSet, basename='actualite')
router.register(r'evenements', EvenementViewSet)
router.register(r'interviews', InterviewViewSet)
router.register(r'chroniques', ChroniqueViewSet)
router.register(r'lives', LiveViewSet)
router.register(r'videos', VideoDiversViewSet)
router.register(r'debats', DebatViewSet)
router.register(r'publicites', PubliciteViewSet, basename='publicite')

urlpatterns = [
    
    path('', include(router.urls))  # ✅ tu dois inclure les URLs du router ici
]