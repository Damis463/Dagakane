from rest_framework import viewsets, serializers
from index.models import Actualite, Debat, Evenement, Chronique, Interview, Live, Musique, Publicite, VideoDivers
Musique, Live



class ChroniqueSerializer(serializers.ModelSerializer):
    class Meta:
        model = Chronique
        fields = '__all__'

class ActualiteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Actualite
        fields ='__all__'




class EvenementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Evenement
        fields ='__all__'




class LiveSerializer(serializers.ModelSerializer):
    class Meta:
        model = Live
        fields ='__all__'









class InterviewSerializer(serializers.ModelSerializer):
    class Meta:
        model = Interview
        fields ='__all__'





class MusiqueSerializer(serializers.ModelSerializer):
    class Meta:
        model = Musique
        fields ='__all__'



    

class ChroniqueSerializer(serializers.ModelSerializer):
    class Meta:
        model = Chronique
        fields ='__all__'






class DebatSerializer(serializers.ModelSerializer):
    class Meta:
        model = Debat
        fields ='__all__'





class PubliciteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Publicite
        fields = '__all__'



class VideoDiversSerializer(serializers.ModelSerializer):
    class Meta:
        model = VideoDivers
        fields = '__all__'
