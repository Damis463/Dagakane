from argparse import Action
import random
from rest_framework.decorators import action



from rest_framework.generics import ListAPIView

from .serializers import PubliciteSerializer
from rest_framework.response import  Response

from rest_framework import viewsets,status
from index.models import Actualite, Debat, Evenement, Live, Musique, Chronique, Interview, Publicite, VideoDivers
from .serializers import ActualiteSerializer, DebatSerializer, EvenementSerializer, InterviewSerializer, ChroniqueSerializer, LiveSerializer, MusiqueSerializer, PubliciteSerializer, VideoDiversSerializer









class LiveViewSet(viewsets.ModelViewSet):
    queryset = Live.objects.all().order_by('-date')
    serializer_class = LiveSerializer

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        instance.vue += 1
        instance.save()
        serializer = self.get_serializer(instance)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def like(self, request, pk=None):
        live = self.get_object()
        live.likes += 1
        live.save()
        return Response({'status': 'like ajouté', 'likes': live.likes})


# Optionnel : permission personnalisée pour lecture publique / écriture admin


class ActualiteViewSet(viewsets.ModelViewSet):
    queryset = Actualite.objects.all().order_by('-date_publication')
    serializer_class = ActualiteSerializer

    @action(detail=True, methods=['post'])
    def increment_vue(self, request, pk=None):
        actualite = self.get_object()
        actualite.vue += 1
        actualite.save()
        return Response({'vue': actualite.vue}, status=status.HTTP_200_OK)

    @action(detail=True, methods=['post'])
    def increment_like(self, request, pk=None):
        actualite = self.get_object()
        actualite.likes += 1
        actualite.save()
        return Response({'likes': actualite.likes}, status=status.HTTP_200_OK)


class EvenementViewSet(viewsets.ModelViewSet):
    queryset = Evenement.objects.all().order_by('-date')
    serializer_class = EvenementSerializer

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        instance.vue += 1
        instance.save()
        serializer = self.get_serializer(instance)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def like(self, request, pk=None):
        evenement = self.get_object()
        evenement.likes += 1
        evenement.save()
        return Response({'status': 'like ajouté', 'likes': evenement.likes})







class InterviewViewSet(viewsets.ModelViewSet):
    queryset = Interview.objects.all().order_by('-date_publication')
    serializer_class = InterviewSerializer

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        instance.vue += 1
        instance.save()
        serializer = self.get_serializer(instance)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def like(self, request, pk=None):
        interview = self.get_object()
        interview.likes += 1
        interview.save()
        return Response({'status': 'like ajouté', 'likes': interview.likes})





class ChroniqueViewSet(viewsets.ModelViewSet):
    queryset = Chronique.objects.all().order_by('-date_publication')
    serializer_class = ChroniqueSerializer

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        instance.vue += 1
        instance.save()
        serializer = self.get_serializer(instance)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def like(self, request, pk=None):
        chronique = self.get_object()
        chronique.likes += 1
        chronique.save()
        return Response({'status': 'like ajouté', 'likes': chronique.likes})








class DebatViewSet(viewsets.ModelViewSet):
    queryset = Debat.objects.all().order_by('-date_publication')
    serializer_class = DebatSerializer

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        instance.vue += 1
        instance.save()
        serializer = self.get_serializer(instance)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def like(self, request, pk=None):
        debat = self.get_object()
        debat.likes += 1
        debat.save()
        return Response({'status': 'like ajouté', 'likes': debat.likes})




class MusiqueViewSet(viewsets.ModelViewSet):
    queryset = Musique.objects.all().order_by('-date_publication')
    serializer_class = MusiqueSerializer

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        instance.vue += 1
        instance.save()
        serializer = self.get_serializer(instance)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def like(self, request, pk=None):
        musique = self.get_object()
        musique.likes += 1
        musique.save()
        return Response({'status': 'like ajouté', 'likes': musique.likes})



class PubliciteViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Publicite.objects.filter(actif=True).order_by('-date_publication')
    serializer_class = PubliciteSerializer




class VideoDiversViewSet(viewsets.ModelViewSet):
    queryset = VideoDivers.objects.all().order_by('-date_publication')
    serializer_class = VideoDiversSerializer

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        instance.incrementer_vue()  # incrémenter vues à chaque accès détail
        serializer = self.get_serializer(instance)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def like(self, request, pk=None):
        video = self.get_object()
        video.likes += 1
        video.save()
        return Response({'status': 'like ajouté', 'likes': video.likes})




class PubliciteActivesView(ListAPIView):
    queryset = Publicite.objects.filter(actif=True).order_by('-date_publication')
    serializer_class = PubliciteSerializer


