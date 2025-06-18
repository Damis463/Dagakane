from datetime import timezone
from xmlrpc.client import DateTime
from django.db import models
from django.shortcuts import render
from django.db import models
from django.utils import timezone  # ✅




class Actualite(models.Model):
    titre = models.CharField(max_length=200)
    contenu = models.TextField()
    image = models.ImageField(upload_to='actualites/', null=True, blank=True)
    video = models.FileField(upload_to='actualites/', null=True, blank=True)
    vue = models.PositiveIntegerField(default=0)
    lecture = models.PositiveIntegerField(default=0) 
    likes = models.PositiveIntegerField(default=0) 
    date_publication = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.titre

# Musique
class Musique(models.Model):
    titre = models.CharField(max_length=200)
    artiste = models.CharField(max_length=100)
    fichier_audio = models.FileField(upload_to='musiques/', blank=True, null=True)
    video = models.FileField(upload_to='musiques/')
    couverture = models.ImageField(upload_to='musiques/covers/', blank=True, null=True)
    vue = models.PositiveIntegerField(default=0)
    lecture = models.PositiveIntegerField(default=0) 
    likes = models.PositiveIntegerField(default=0) 
    date_publication = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.titre} - {self.artiste}"

# Événements
class Evenement(models.Model):
    titre = models.CharField(max_length=200)
    description = models.TextField()
    date = models.DateField()
    lieu = models.CharField(max_length=200)
    image = models.ImageField(upload_to='evenements/', blank=True, null=True)
    video = models.FileField(upload_to='evenement/', blank=True, null=True)
    vue = models.PositiveIntegerField(default=0)
    lecture = models.PositiveIntegerField(default=0) 
    likes = models.PositiveIntegerField(default=0) 
    def __str__(self):
        return f"{self.titre} - {self.lieu}"


class Interview(models.Model):
    titre = models.CharField(max_length=200)
    personne = models.CharField(max_length=100)
    video = models.FileField(upload_to='interviews/')
    resume = models.TextField(blank=True, null=True)
    vue = models.PositiveIntegerField(default=0)
    lecture = models.PositiveIntegerField(default=0) 
    likes = models.PositiveIntegerField(default=0) 
    date_publication = models.DateTimeField(auto_now_add=True)
    def __str__(self):
        return f"Interview de {self.personne}"



class Chronique(models.Model):
    titre = models.CharField(max_length=200)
    contenu = models.TextField()
    auteur = models.CharField(max_length=100)
    video = models.FileField(upload_to='evenement/', blank=True, null=True)
    vue = models.PositiveIntegerField(default=0)
    lecture = models.PositiveIntegerField(default=0) 
    likes = models.PositiveIntegerField(default=0) 
    date_publication = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.titre} par {self.auteur}"


class Publicite(models.Model):
    message = models.CharField(max_length=255)
    image = models.ImageField(upload_to='publicites/images/', blank=True, null=True)
    video = models.FileField(upload_to='publicites/videos/', blank=True, null=True)
    actif = models.BooleanField(default=True)
    date_publication = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.message



class Live(models.Model):
    PLATFORM_CHOICES = [
        ('youtube', 'YouTube'),
        ('facebook', 'Facebook'),
        ('tiktok', 'TikTok'),
    ]

    titre = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    platform = models.CharField(max_length=10, choices=PLATFORM_CHOICES)
    url = models.URLField()  # lien d'intégration du live
    date = models.DateTimeField(auto_now_add=True)
    vue = models.PositiveIntegerField(default=0)
    lecture = models.PositiveIntegerField(default=0) 
    likes = models.PositiveIntegerField(default=0) 
    def __str__(self):
        return f"{self.titre} - {self.platform}"








class Debat(models.Model):
    theme = models.CharField(max_length=200)
    lieu = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    participants = models.TextField(blank=True)  # liste des participants
    video = models.FileField(upload_to='debat/')
    vue = models.PositiveIntegerField(default=0)
    lecture = models.PositiveIntegerField(default=0) 
    likes = models.PositiveIntegerField(default=0) 
    date_publication = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.theme



class CategorieVideo(models.Model):
    nom = models.CharField(max_length=100, unique=True)

    def __str__(self):
        return self.nom

class VideoDivers(models.Model):
    CATEGORIES_CHOICES = [
        ('theatre', 'Théâtre'),
        ('quiz', 'Quiz'),
        ('experience_sociale', 'Expérience sociale'),
        ('humour', 'Humour'),
        ('autre', 'Autre'),
    ]

    titre = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    categorie = models.CharField(max_length=50, choices=CATEGORIES_CHOICES)
    categorie_personnalisee = models.ForeignKey(CategorieVideo, null=True, blank=True, on_delete=models.SET_NULL)
    fichier_video = models.FileField(upload_to='videos/')
    miniature = models.ImageField(upload_to='miniatures/', null=True, blank=True)
    date_publication = models.DateTimeField(default=timezone.now)
    nombre_vues = models.PositiveIntegerField(default=0)
    likes = models.PositiveIntegerField(default=0)

    def __str__(self):
        return self.titre

    def incrementer_vue(self):
        self.nombre_vues += 1
        self.save()
