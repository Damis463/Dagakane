class Musique {
  final String titre;
  final String artiste;
  final String? fichier_audio;
  final String? video;
  final String? couverture;
  int vue;
  int lecture;
  int likes;
  final DateTime date_publication;

  Musique({
    required this.titre,
    required this.artiste,
    this.fichier_audio,
    this.video,
    this.couverture,
    this.vue = 0,
    this.lecture = 0,
    this.likes = 0,
    required this.date_publication,
  });

}
