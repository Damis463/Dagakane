import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VideoDiversPage extends StatefulWidget {
  const VideoDiversPage({Key? key}) : super(key: key);

  @override
  _VideoDiversPageState createState() => _VideoDiversPageState();
}

class _VideoDiversPageState extends State<VideoDiversPage> {
  List<dynamic> videos = [];
  bool isLoading = true;
  bool hasError = false;
  String? selectedCategory;

  final categories = [
    'Toutes',
    'Théâtre',
    'Quiz',
    'Expérience sociale',
    'Humour',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  Future<void> _fetchVideos() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    const apiUrl = 'http://localhost:8000/api/videos/';

    try {
      final resp = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final data = json.decode(utf8.decode(resp.bodyBytes));
        setState(() {
          videos = data;
          isLoading = false;
        });
      } else {
        throw Exception('Erreur serveur: ${resp.statusCode}');
      }
    } catch (_) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  List<dynamic> get filteredVideos {
    if (selectedCategory == null || selectedCategory == 'Toutes') return videos;
    return videos
        .where((v) => _mapApiToDisplay(v['categorie']) == selectedCategory)
        .toList();
  }

  String _mapApiToDisplay(String api) {
    switch (api) {
      case 'theatre':
        return 'Théâtre';
      case 'quiz':
        return 'Quiz';
      case 'experience_sociale':
        return 'Expérience sociale';
      case 'humour':
        return 'Humour';
      case 'autre':
        return 'Autre';
      default:
        return api;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vidéo Divers'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchVideos),
        ],
      ),
      body: Column(
        children: [
          _buildFilter(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildFilter() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonFormField<String>(
          value: selectedCategory ?? 'Toutes',
          decoration: const InputDecoration(
            border: InputBorder.none,
            labelText: 'Filtrer par catégorie',
          ),
          items: categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (c) => setState(() => selectedCategory = c),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Erreur de chargement des vidéos'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchVideos,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (filteredVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              selectedCategory == null || selectedCategory == 'Toutes'
                  ? 'Aucune vidéo disponible'
                  : 'Aucune vidéo dans cette catégorie',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: filteredVideos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75, // Meilleur ratio pour les cartes vidéo
      ),
      itemBuilder: (context, index) => _buildVideoCard(filteredVideos[index]),
    );
  }

  Widget _buildVideoCard(Map video) {
    final titre = video['titre'] ?? 'Sans titre';
    final desc = video['description'] ?? '';
    final mini = video['miniature'] ?? '';
    final date = video['date_publication'] ?? '';
    final vues = video['nombre_vues'] ?? 0;
    final likes = video['likes'] ?? 0;
    final categorie = _mapApiToDisplay(video['categorie'] ?? '');

    final formattedDate = date.isNotEmpty
        ? DateFormat('dd/MM/yy').format(DateTime.parse(date))
        : '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onTapVideo(video),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Miniature avec badge de catégorie
            Stack(
              children: [
                // Image de la miniature
                Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: mini.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: mini,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.videocam_off,
                            color: Colors.grey,
                          ),
                        )
                      : const Icon(Icons.videocam, color: Colors.grey),
                ),
                // Badge de catégorie
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      categorie,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                // Icône play
                const Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.play_circle_filled,
                      size: 48,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
            // Contenu texte
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    titre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    desc,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Stats et date
                  Row(
                    children: [
                      // Vues
                      Row(
                        children: [
                          const Icon(
                            Icons.visibility,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            vues.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Likes
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _onLike(video['id'], video),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.thumb_up,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              likes.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Date
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onTapVideo(Map video) async {
    final id = video['id'];
    await http.post(Uri.parse('http://localhost:8000/api/videos/$id/vue/'));
    setState(() => video['nombre_vues'] = (video['nombre_vues'] ?? 0) + 1);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          videoUrl: video['fichier_video'] ?? '',
          videoTitle: video['titre'] ?? '',
        ),
      ),
    );
  }

  Future<void> _onLike(int id, Map video) async {
    final resp = await http.post(
      Uri.parse('http://localhost:8000/api/videos/$id/like/'),
    );
    if (resp.statusCode == 200) {
      final newLikes = json.decode(resp.body)['likes'];
      setState(() => video['likes'] = newLikes);
    }
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;

  const VideoPlayerScreen({
    Key? key,
    required this.videoUrl,
    required this.videoTitle,
  }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController controller;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
        isPlaying = false;
      } else {
        controller.play();
        isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.videoTitle)),
      body: controller.value.isInitialized
          ? Column(
              children: [
                AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: GestureDetector(
                    onTap: _toggle,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(controller),
                        if (!controller.value.isPlaying)
                          const Icon(
                            Icons.play_circle_outline,
                            size: 80,
                            color: Colors.white70,
                          ),
                      ],
                    ),
                  ),
                ),
                VideoProgressIndicator(controller, allowScrubbing: true),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: _toggle,
                    ),
                    IconButton(
                      icon: const Icon(Icons.replay_10),
                      onPressed: () {
                        final current = controller.value.position;
                        controller.seekTo(
                          current - const Duration(seconds: 10),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_10),
                      onPressed: () {
                        final current = controller.value.position;
                        controller.seekTo(
                          current + const Duration(seconds: 10),
                        );
                      },
                    ),
                  ],
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
