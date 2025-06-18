class Actualite {
  final int id;
  final String titre;
  final String contenu;
  final String? image;
  final String? video;
  final String date;

  Actualite({
    required this.id,
    required this.titre,
    required this.contenu,
    this.image,
    this.video,
    required this.date,
  });

  factory Actualite.fromJson(Map<String, dynamic> json) {
    return Actualite(
      id: json['id'],
      titre: json['titre'],
      contenu: json['contenu'],
      image: json['image'],
      video: json['video'],
      date: json['date'],
    );
  }
}
