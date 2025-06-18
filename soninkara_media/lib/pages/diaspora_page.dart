import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

class DiasporaPage extends StatefulWidget {
  const DiasporaPage({super.key});

  @override
  State<DiasporaPage> createState() => _DiasporaPageState();
}

class _DiasporaPageState extends State<DiasporaPage> {
  List<dynamic> diasporaList = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  VideoPlayerController? _videoController;
  int? _expandedItemIndex;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchDiaspora();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchDiaspora() async {
    const apiUrl = 'http://localhost:8000/api/diasporas/';

    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            diasporaList = data;
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
              'Impossible de charger les contenus. Veuillez réessayer.';
        });
      }
    }
  }

  void _toggleItemExpansion(int index) {
    setState(() {
      if (_expandedItemIndex == index) {
        _expandedItemIndex = null;
        _videoController?.dispose();
        _videoController = null;
      } else {
        _expandedItemIndex = index;
        final videoUrl = diasporaList[index]['video']?.toString();
        if (videoUrl != null && videoUrl.isNotEmpty) {
          _videoController = VideoPlayerController.network(videoUrl)
            ..initialize().then((_) {
              if (mounted) setState(() {});
              _videoController?.play();
            });
        }
      }
    });
  }

  Future<void> _launchWhatsApp() async {
    const phoneNumber = '+22371939375'; // Remplacez par votre numéro
    const message =
        'Bonjour, je souhaite partager mon témoignage sur la diaspora Soninké';
    final url =
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir WhatsApp')),
        );
      }
    }
  }

  void _navigateToFullScreenVideo(BuildContext context) {
    if (_videoController == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Vidéo en plein écran'),
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

  Widget _buildDiasporaItem(Map<String, dynamic> item, int index) {
    final nom = item['nom']?.toString() ?? 'Anonyme';
    final ville = item['ville']?.toString() ?? 'Ville inconnue';
    final texte = item['texte']?.toString() ?? '';
    final date = item['date']?.toString() ?? '';
    final photoUrl = item['photo']?.toString();
    final videoUrl = item['video']?.toString();

    final formattedDate = date.isNotEmpty
        ? DateFormat(
            'EEEE d MMMM y à HH:mm',
            'fr_FR',
          ).format(DateTime.parse(date))
        : 'Date inconnue';

    final isExpanded = _expandedItemIndex == index;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photoUrl != null && photoUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: CachedNetworkImage(
                imageUrl: photoUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.person, size: 50, color: Colors.grey),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 20,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      nom,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_city,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ville,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
                    texte,
                    style: const TextStyle(fontSize: 15, height: 1.5),
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
            onTap: () => _toggleItemExpansion(index),
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
                    isExpanded ? 'REDUIRE' : 'VOIR TÉMOIGNAGE',
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
        title: const Text('Diaspora Soninké'),
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
            onPressed: _fetchDiaspora,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.message, color: Colors.white),
        onPressed: _launchWhatsApp,
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
                    onPressed: _fetchDiaspora,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
          : diasporaList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Aucun témoignage disponible',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.message, color: Colors.white),
                    label: const Text('Messagez-nous sur WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: _launchWhatsApp,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchDiaspora,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: diasporaList.length,
                itemBuilder: (context, index) {
                  return _buildDiasporaItem(diasporaList[index], index);
                },
              ),
            ),
    );
  }
}
