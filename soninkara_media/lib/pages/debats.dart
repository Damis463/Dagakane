// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DebatPage extends StatefulWidget {
  const DebatPage({Key? key}) : super(key: key);

  @override
  _DebatPageState createState() => _DebatPageState();
}

class _DebatPageState extends State<DebatPage> {
  List<dynamic> debats = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  Set<int> likedDebats = {};

  @override
  void initState() {
    super.initState();
    _loadLikedDebats();
    _fetchDebats();
  }

  Future<void> _loadLikedDebats() async {
    final prefs = await SharedPreferences.getInstance();
    final liked = prefs.getStringList('liked_debats') ?? [];
    setState(() {
      likedDebats = liked.map(int.parse).toSet();
    });
  }

  Future<void> _saveLikedDebats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'liked_debats',
      likedDebats.map((id) => id.toString()).toList(),
    );
  }

  Future<void> _fetchDebats() async {
    const apiUrl = 'http://localhost:8000/api/debats/';

    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            debats = data;
            isLoading = false;
            hasError = false;
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
          errorMessage =
              'Impossible de charger les débats. Veuillez réessayer.';
        });
      }
      debugPrint('Erreur de connexion: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    await _fetchDebats();
  }

  Future<void> _incrementLike(Map<String, dynamic> debat) async {
    final id = debat['id'] as int;

    if (likedDebats.contains(id)) {
      return; // L'utilisateur a déjà liké ce débat
    }

    final url = 'http://localhost:8000/api/debats/$id/increment_like/';

    try {
      final response = await http
          .post(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          debat['likes'] = data['likes'];
          likedDebats.add(id);
        });
        await _saveLikedDebats();
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

  Future<void> _incrementVue(Map<String, dynamic> debat) async {
    final id = debat['id'].toString();
    final url = 'http://localhost:8000/api/debats/$id/increment_vue/';

    try {
      final response = await http
          .post(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          debat['vue'] = data['vue'];
        });
      }
    } catch (e) {
      debugPrint('Erreur vue: $e');
    }
  }

  void _navigateToDetail(Map<String, dynamic> debat) async {
    await _incrementVue(debat);
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DebatDetailPage(debat: debat)),
    ).then((_) {
      if (mounted) setState(() {}); // Rafraîchir après retour
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Débats'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
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

    if (debats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.forum, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aucun débat disponible',
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
      child: ListView.separated(
        itemCount: debats.length,
        padding: const EdgeInsets.all(16),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _buildDebatCard(debats[index]),
      ),
    );
  }

  Widget _buildDebatCard(Map<String, dynamic> debat) {
    final id = debat['id'] as int;
    final theme = debat['theme']?.toString() ?? 'Sans thème';
    final lieu = debat['lieu']?.toString() ?? '';
    final description = debat['description']?.toString() ?? '';
    final participants = debat['participants']?.toString() ?? '';
    final date = debat['date_publication']?.toString() ?? '';
    final vues = debat['vue'] ?? 0;
    final lectures = debat['lecture'] ?? 0;
    final likes = debat['likes'] ?? 0;

    final formattedDate = date.isNotEmpty
        ? DateFormat('dd MMM yyyy', 'fr_FR').format(DateTime.parse(date))
        : '';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToDetail(debat),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(
                      Icons.video_library,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (lieu.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(lieu, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    description.length > 100
                        ? '${description.substring(0, 100)}...'
                        : description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  if (participants.isNotEmpty) ...[
                    const Text(
                      'Participants:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      participants,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      _buildStatItem(Icons.remove_red_eye, vues.toString()),
                      const SizedBox(width: 16),
                      _buildStatItem(Icons.menu_book, lectures.toString()),
                      const SizedBox(width: 16),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _incrementLike(debat),
                        child: _buildStatItem(
                          Icons.thumb_up,
                          likes.toString(),
                          isLiked: likedDebats.contains(id),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formattedDate,
                        style: const TextStyle(color: Colors.grey),
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
}

class DebatDetailPage extends StatefulWidget {
  final Map<String, dynamic> debat;

  const DebatDetailPage({Key? key, required this.debat}) : super(key: key);

  @override
  _DebatDetailPageState createState() => _DebatDetailPageState();
}

class _DebatDetailPageState extends State<DebatDetailPage> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.debat['video'] ?? '')
      ..setLooping(false);
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.debat['theme']?.toString() ?? 'Débat';
    final lieu = widget.debat['lieu']?.toString() ?? '';
    final description = widget.debat['description']?.toString() ?? '';
    final participants = widget.debat['participants']?.toString() ?? '';
    final date = widget.debat['date_publication']?.toString() ?? '';
    final likes = widget.debat['likes'] ?? 0;
    final vues = widget.debat['vue'] ?? 0;

    final formattedDate = date.isNotEmpty
        ? DateFormat('dd MMMM yyyy', 'fr_FR').format(DateTime.parse(date))
        : '';

    return Scaffold(
      appBar: AppBar(title: Text(theme)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FutureBuilder(
                    future: _initializeVideoPlayerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return VideoPlayer(_controller);
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                  if (!_isPlaying)
                    IconButton(
                      icon: const Icon(
                        Icons.play_arrow,
                        size: 60,
                        color: Colors.white,
                      ),
                      onPressed: _togglePlay,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (lieu.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 20),
                        const SizedBox(width: 8),
                        Text(lieu, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  if (description.isNotEmpty) ...[
                    const Text(
                      'Description:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(description, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                  ],
                  if (participants.isNotEmpty) ...[
                    const Text(
                      'Participants:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(participants, style: const TextStyle(fontSize: 16)),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatItem(Icons.remove_red_eye, vues.toString()),
                      const SizedBox(width: 16),
                      _buildStatItem(Icons.thumb_up, likes.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _togglePlay,
        child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
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
