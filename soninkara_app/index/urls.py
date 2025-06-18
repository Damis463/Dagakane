from django.urls import path, include



from . import views


# URL patterns
urlpatterns = [
    path('', views.home, name='home'),
    
    # Pages web (vues classiques)
    path('actualites/', views.actualites_list, name='actualites'),
    path('actualites/<slug:slug>/', views.actualite_detail, name='actualite_detail'),
    path('actualites_list/', views.actualites_list, name='actualites_list'),
    
 

    path('musique/<int:id>/', views.musique_detail, name='musique_detail'),
    path('musique_list/', views.musique_list, name='musiques_list'),

    path('debats/', views.debat_list, name='debat_list'),
    path('debats/<int:debat_id>/', views.debat_detail, name='debat_detail'),
    path('debats/<int:debat_id>/like/', views.debat_like, name='debat_like'),
    path('debats/<int:debat_id>/lecture/', views.debat_lecture, name='debat_lecture'),


    path('videos/', views.VideoDivers, name='videos'),
    path('api/videos/<int:pk>/vue/', views.increment_vue),
    path('api/videos/<int:pk>/like/', views.increment_like),


    path('interviews/', views.interviews_list, name='interviews'),
   # path('interview/<int:id>/', views.Interview_detail, name='interview_detail'),
    path('actualites/<int:pk>/increment_vue/', views.increment_vue, name='increment_vue'),
    path('actualites/<int:pk>/increment_like/', views.increment_like, name='increment_like'),




    path('chronique/', views.chronique_list, name='chronique_list'),
    path('chronique/<int:chronique_id>/', views.chronique_detail, name='chronique_detail'),
    path('chronique/<int:chronique_id>/like/', views.chronique_like, name='chronique_like'),
    path('debats/<int:chronique_id>/lecture/', views.chronique_lecture, name='chronique_lecture'),


    path('evenements/', views.evenement_list, name='evenement_list'),
    path('evenement/<int:evenement_id>/', views.evenement_detail, name='evenement_detail'),
    path('evenement/<int:evenement_id>/like/', views.evenement_like, name='evenement_like'),
    path('evenement/<int:evenemet_id>/lecture/', views.evenement_lecture, name='evenement_lecture'),


    ]