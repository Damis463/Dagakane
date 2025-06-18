import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:soninkara_media/pages/actualite_detail.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActualitePage extends StatefulWidget {
  const ActualitePage({super.key});

  @override
  State<ActualitePage> createState() => _ActualitePageState();
}

class _ActualitePageState extends State<ActualitePage> {
  List<dynamic> actualites = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  bool isRefreshing = false;
  Set<int> likedArticles = {};

  @override
  void initState() {
    super.initState();
    _loadLikedArticles();
    _fetchActualites();
  }

  Future<void> _loadLikedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final liked = prefs.getStringList('liked_articles') ?? [];
    setState(() {
      likedArticles = liked.map(int.parse).toSet();
    });
  }

  Future<void> _saveLikedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'liked_articles',
      likedArticles.map((id) => id.toString()).toList(),
    );
  }

  Future<void> _fetchActualites() async {
    const apiUrl = 'http://localhost:8000/api/actualites/';

    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            actualites = data;
            isLoading = false;
            hasError = false;
            isRefreshing = false;
          });
        }
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          isRefreshing = false;
          errorMessage = 'Connexion échouée. Vérifiez votre internet';
        });
      }
      debugPrint('Erreur de connexion: $e');
    }
  }

  Future<void> _refreshData() async {
    if (isRefreshing) return;

    setState(() {
      isRefreshing = true;
      hasError = false;
    });
    await _fetchActualites();
  }

  Future<void> _incrementLike(Map<String, dynamic> actu) async {
    final id = actu['id'] as int;

    if (likedArticles.contains(id)) {
      return; // L'utilisateur a déjà liké cet article
    }

    final url = 'http://localhost:8000/api/actualites/$id/increment_like/';

    try {
      final response = await http
          .post(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          actu['likes'] = data['likes'];
          likedArticles.add(id);
        });
        await _saveLikedArticles();
      } else {
        debugPrint('Erreur like: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur like: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Échec de la mise à jour des likes')),
      );
    }
  }

  Future<void> _incrementVue(Map<String, dynamic> actu) async {
    final id = actu['id'].toString();
    final url = 'http://localhost:8000/api/actualites/$id/increment_vue/';

    try {
      final response = await http
          .post(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          actu['vue'] = data['vue'];
        });
      }
    } catch (e) {
      debugPrint('Erreur vue: $e');
    }
  }

  void _navigateToDetail(Map<String, dynamic> actu) async {
    await _incrementVue(actu);
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailPage(actu: actu)),
    ).then((_) {
      if (mounted) setState(() {}); // Rafraîchir après retour
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }

  Widget _buildBody() {
    if (isLoading && !isRefreshing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (actualites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.article, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aucune actualité disponible',
              style: TextStyle(fontSize: 16),
            ),
            TextButton(
              onPressed: _refreshData,
              child: const Text('Actualiser'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      displacement: 40,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: actualites.length,
        padding: const EdgeInsets.all(16),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _buildActuItem(actualites[index]),
      ),
    );
  }

  Widget _buildActuItem(Map<String, dynamic> actu) {
    final id = actu['id'] as int;
    final titre = actu['titre']?.toString() ?? 'Sans titre';
    final contenu = actu['contenu']?.toString() ?? '';
    final image = actu['image']?.toString();
    final video = actu['video']?.toString();
    final date = actu['date_publication']?.toString() ?? '';
    final vues = actu['vue'] ?? 0;
    final lectures = actu['lecture'] ?? 0;
    final likes = actu['likes'] ?? 0;

    final formattedDate = date.isNotEmpty
        ? DateFormat('dd MMM yyyy', 'fr_FR').format(DateTime.parse(date))
        : '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToDetail(actu),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (image != null || video != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: _buildMediaWidget(image, video),
                    ),
                  ),
                ),
              Text(
                titre,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                contenu.length > 150
                    ? '${contenu.substring(0, 150)}...'
                    : contenu,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatItem(Icons.remove_red_eye, vues.toString()),
                  const SizedBox(width: 16),
                  _buildStatItem(Icons.menu_book, lectures.toString()),
                  const SizedBox(width: 16),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _incrementLike(actu),
                    child: _buildStatItem(
                      Icons.thumb_up,
                      likes.toString(),
                      isLiked: likedArticles.contains(id),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formattedDate,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
              if (contenu.length > 150)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                    ),
                    onPressed: () => _navigateToDetail(actu),
                    child: const Text(
                      'Lire la suite',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, {bool isLiked = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: isLiked ? Colors.blue : Colors.grey),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: isLiked ? Colors.blue : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaWidget(String? image, String? video) {
    if (video != null && video.isNotEmpty) {
      return _VideoThumbnailWidget(videoUrl: video);
    } else if (image != null && image.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: image,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    } else {
      return Container(
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.article, color: Colors.grey)),
      );
    }
  }
}

class _VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;

  const _VideoThumbnailWidget({required this.videoUrl});

  @override
  State<_VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<_VideoThumbnailWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _showPlayButton = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..setLooping(false)
      ..setVolume(0);
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      if (mounted) {
        setState(() {});
        _controller.pause();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              );
            } else {
              return Container(
                color: Colors.black,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
        if (_showPlayButton)
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  void _togglePlay() {
    setState(() {
      _showPlayButton = !_showPlayButton;
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
