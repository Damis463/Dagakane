import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class ChroniquePage extends StatefulWidget {
  const ChroniquePage({super.key});

  @override
  State<ChroniquePage> createState() => _ChroniquePageState();
}

class _ChroniquePageState extends State<ChroniquePage> {
  List<dynamic> chroniques = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  VideoPlayerController? _videoController;
  int? _expandedIndex;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchChroniques();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchChroniques() async {
    const apiUrl = 'http://localhost:8000/api/chronique/';

    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            chroniques = data;
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
              'Impossible de charger les chroniques. Veuillez réessayer.';
        });
      }
    }
  }

  void _toggleExpand(int index) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null;
        _videoController?.dispose();
        _videoController = null;
      } else {
        _expandedIndex = index;
        final videoUrl = chroniques[index]['video']?.toString();
        if (videoUrl != null && videoUrl.isNotEmpty) {
          _videoController = VideoPlayerController.network(videoUrl)
            ..initialize().then((_) {
              if (mounted) setState(() {});
            });
        }
      }
    });
  }

  void _navigateToFullScreenVideo(BuildContext context) {
    if (_videoController == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Chronique vidéo'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context) {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Container(
        height: 200,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: () => _navigateToFullScreenVideo(context),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_videoController!),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _videoController!.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                size: 50,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChroniqueItem(Map<String, dynamic> chronique, int index) {
    final titre = chronique['titre']?.toString() ?? 'Chronique sans titre';
    final contenu = chronique['contenu']?.toString() ?? '';
    final auteur = chronique['auteur']?.toString() ?? 'Auteur inconnu';
    final videoUrl = chronique['video']?.toString();
    final date = chronique['date_publication']?.toString() ?? '';

    final formattedDate = date.isNotEmpty
        ? DateFormat('EEEE d MMMM y', 'fr_FR').format(DateTime.parse(date))
        : 'Date inconnue';

    final isExpanded = _expandedIndex == index;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      auteur,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    contenu,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                  if (videoUrl != null && videoUrl.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildVideoPlayer(context),
                  ],
                ],
              ],
            ),
          ),
          InkWell(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            onTap: () => _toggleExpand(index),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isExpanded ? 'REDUIRE' : 'LIRE LA CHRONIQUE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.blue[700],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chroniques'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implémenter la recherche
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchChroniques,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(errorMessage),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _fetchChroniques,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
          : chroniques.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.article, size: 60, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text(
                    'Aucune chronique disponible',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchChroniques,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: chroniques.length,
                itemBuilder: (context, index) {
                  return _buildChroniqueItem(chroniques[index], index);
                },
              ),
            ),
    );
  }
}
