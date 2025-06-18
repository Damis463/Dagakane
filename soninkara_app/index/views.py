from django.http import JsonResponse
from django.shortcuts import render



# views.py
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

from .models import VideoDivers
# Create your views here.
from django.shortcuts import render, get_object_or_404

from rest_framework.response import Response
from rest_framework import status
from rest_framework.response import Response
from rest_framework import status
from django.core.paginator import Paginator
from .models import (
    Actualite, Musique, Evenement,
    Interview, Chronique, Live, VideoDivers 
)




def home(request) :
    Actualites = Actualite.objects.all().order_by('-date_publication')[ :4]
    Musiques = Musique.objects.order_by('-date_publication')[ :3]
    Evenements = Evenement.objects.order_by('date')[ :3]
    Chroniques = Chronique.objects.order_by('-date_publication').first()

    Context = {
        'actualites'  : Actualites,
        'musiques'    : Musiques,
        'evenements'  : Evenements,
        'chronique'   : Chroniques,
    }
    return render(request, 'home.html', Context)


def a_la_une(request) :
    A_la_une = Actualite.objects.filter(en_vedette=True).first()
    return render(request, 'home.html',{'a_la_une' : a_la_une})


def evenement_list(request):
    evenements = Evenement.objects.order_by('-date_publication')
    return render(request, 'evenement_list.html', {'evenements': evenements})


def evenement_detail(request, evenement_id):
    evenement = get_object_or_404(Debat, id=evenement_id)
    evenement.vue += 1
    evenement.save()
    return render(request, 'evenement_detail.html', {'evenement': evenement})

# Vue pour ajouter un like (Ajax)
def evenement_like(request, evenement_id):
    evenement = get_object_or_404(Debat, id=evenement_id)
    evenement.likes += 1
    evenement.save()
    return JsonResponse({'likes': evenement.likes})

# Vue pour ajouter une lecture (Ajax)
def evenement_lecture(request, evenement_id):
    evenement = get_object_or_404(Debat, id=evenement_id)
    evenement.lecture += 1
    evenement.save()
    return JsonResponse({'lecture': evenement.lecture})









def interviews_list(request):
    interviews = Interview.objects.all().order_by('-date_publication')  # toute la liste
    paginator = Paginator(interviews, 5)  # 5 actualités par page
    Page_number = request.GET.get('page')  # récupère ?page=2 depuis l’URL
    Page_obj = paginator.get_page(Page_number)  # découpe proprement même si page=999

    return render(request, 'interview_list.html', {'page_obj' : Page_obj})







def actualites_list(request) :
    Actualites = Actualite.objects.all().order_by('-date_publication')  # toute la liste
    paginator = Paginator(Actualites, 5)  # 5 actualités par page
    Page_number = request.GET.get('page')  # récupère ?page=2 depuis l’URL
    Page_obj = paginator.get_page(Page_number)  # découpe proprement même si page=999

    return render(request, 'actualiteslist.html', {'page_obj' : Page_obj})


def actualite_detail(request, slug):
    actualite = get_object_or_404(Actualite, slug=slug)
    return render(request, 'actualitesdetail.html', {'actualite': actualite})


def increment_vue(request, pk):
    if request.method == 'POST':
        actualite = get_object_or_404(Actualite, pk=pk)
        actualite.nombre_vues += 1
        actualite.save()
        return JsonResponse({'status': 'success', 'nombre_vues': actualite.nombre_vues})
    else:
        return JsonResponse({'status': 'error', 'message': 'Requête non autorisée'}, status=400)










# Vue liste des chronique
def chronique_list(request):
    chronique = Chronique.objects.order_by('-date_publication')
    return render(request, 'chonique_list.html', {'chonique': chronique})

# Vue détail d’un débat
def chronique_detail(request, chronique_id):
    chronique = get_object_or_404(Chronique, id=chronique_id)
    chronique.vue += 1
    chronique.save()
    return render(request, 'chronique_detail.html', {'chronique': chronique})

# Vue pour ajouter un like (Ajax)
def chronique_like(request, chronique_id):
    chronique = get_object_or_404(chronique, id=chronique_id)
    chronique.likes += 1
    chronique.save()
    return JsonResponse({'likes': chronique.likes})

# Vue pour ajouter une lecture (Ajax)
def chronique_lecture(request, debat_id):
    chronique = get_object_or_404(Debat, id=debat_id)
    chronique.lecture += 1
    chronique.save()
    return JsonResponse({'lecture': chronique.lecture})






def Lives(request):
    live_streams = Live.objects.all().order_by('-date')
    return render(request, 'live.html', {'lives': live_streams})





def detail_video(request, pk):
    video = get_object_or_404(VideoDivers, pk=pk)
    video.incrementer_vue()
    return render(request, 'videos/detail.html', {'video': video})








@api_view(['POST'])
def increment_vue(request, pk):
    try:
        video = VideoDivers.objects.get(pk=pk)
        video.incrementer_vue()
        return Response({'vues': video.nombre_vues})
    except VideoDivers.DoesNotExist:
        return Response({'error': 'Vidéo non trouvée'}, status=status.HTTP_404_NOT_FOUND)

@api_view(['POST'])
def increment_like(request, pk):
    try:
        video = VideoDivers.objects.get(pk=pk)
        video.likes += 1
        video.save()
        return Response({'likes': video.likes})
    except VideoDivers.DoesNotExist:
        return Response({'error': 'Vidéo non trouvée'}, status=status.HTTP_404_NOT_FOUND)


from django.shortcuts import render, get_object_or_404
from .models import Debat
from django.http import JsonResponse

# Vue liste des débats
def debat_list(request):
    debats = Debat.objects.order_by('-date_publication')
    return render(request, 'debat/list.html', {'debats': debats})

# Vue détail d’un débat
def debat_detail(request, debat_id):
    debat = get_object_or_404(Debat, id=debat_id)
    debat.vue += 1
    debat.save()
    return render(request, 'debat/detail.html', {'debat': debat})

# Vue pour ajouter un like (Ajax)
def debat_like(request, debat_id):
    debat = get_object_or_404(Debat, id=debat_id)
    debat.likes += 1
    debat.save()
    return JsonResponse({'likes': debat.likes})

# Vue pour ajouter une lecture (Ajax)
def debat_lecture(request, debat_id):
    debat = get_object_or_404(Debat, id=debat_id)
    debat.lecture += 1
    debat.save()
    return JsonResponse({'lecture': debat.lecture})




# Vue liste des débats
def musique_list(request):
    musiques = Debat.objects.order_by('-date_publication')
    return render(request, 'debat/list.html', {'musiques': musiques})

# Vue détail d’un débat
def musique_detail(request, musique_id):
    musique = get_object_or_404(Musique, id=musique_id)
    musique.vue += 1
    musique.save()
    return render(request, 'musique_detail.html', {'musique': musique})

# Vue pour ajouter un like (Ajax)
def musique_like(request, musique_id):
    musique = get_object_or_404(Musique, id=musique_id)
    musique.likes += 1
    musique.save()
    return JsonResponse({'likes': musique.likes})

# Vue pour ajouter une lecture (Ajax)
def musique_lecture(request, musique_id):
    musique = get_object_or_404(Musique, id=musique_id)
    musique.lecture += 1
    musique.save()
    return JsonResponse({'lecture': musique.lecture})