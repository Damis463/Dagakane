import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class EvenementPage extends StatefulWidget {
  final Evenement evenement;

  const EvenementPage({Key? key, required this.evenement}) : super(key: key);

  @override
  _EvenementPageState createState() => _EvenementPageState();
}

class _EvenementPageState extends State<EvenementPage> {
  late VideoPlayerController _videoController;
  bool _isVideoPlaying = false;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    if (widget.evenement.video != null) {
      _initializeVideoPlayer();
    }
  }

  void _initializeVideoPlayer() {
    _videoController = VideoPlayerController.network(widget.evenement.video!)
      ..initialize().then((_) {
        setState(() {});
        _videoController.setLooping(true);
        
        // Incrémenter le compteur de vues lors de l'initialisation
        setState(() {
          widget.evenement.vue++;
        });
      });
  }

  @override
  void dispose() {
    if (widget.evenement.video != null) {
      _videoController.dispose();
    }
    super.dispose();
  }

  void _toggleVideoPlayPause() {
    setState(() {
      if (_isVideoPlaying) {
        _videoController.pause();
      } else {
        _videoController.play();
      }
      _isVideoPlaying = !_isVideoPlaying;
    });
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      widget.evenement.likes += _isLiked ? 1 : -1;
      // Ici vous devriez appeler une API pour mettre à jour le like
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.evenement.titre),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareEvent,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image ou Video de l'événement
            _buildMediaSection(),
            
            // Informations de base
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.evenement.titre,
                    style: Theme.of(context).textTheme.headline5?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd MMMM yyyy').format(widget.evenement.date),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        widget.evenement.lieu,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(),
                ],
              ),
            ),
            
            // Statistiques
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.visibility, '${widget.evenement.vue}'),
                  _buildStatItem(Icons.play_circle_outline, '${widget.evenement.lecture}'),
                  GestureDetector(
                    onTap: _toggleLike,
                    child: _buildStatItem(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      '${widget.evenement.likes}',
                      color: _isLiked ? Colors.red : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Divider(),
            
            // Description
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.evenement.description,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.evenement.video != null
          ? FloatingActionButton(
              onPressed: _toggleVideoPlayPause,
              child: Icon(
                _isVideoPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
    );
  }

  Widget _buildMediaSection() {
    if (widget.evenement.video != null && _videoController.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _videoController.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_videoController),
            if (!_isVideoPlaying)
              Container(
                color: Colors.black26,
                child: Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    size: 64,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
          ],
        ),
      );
    } else if (widget.evenement.image != null) {
      return CachedNetworkImage(
        imageUrl: widget.evenement.image!,
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 250,
          color: Colors.grey[200],
          child: Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          height: 250,
          color: Colors.grey[200],
          child: Icon(Icons.error),
        ),
      );
    } else {
      return Container(
        height: 250,
        color: Colors.grey[200],
        child: Center(
          child: Icon(
            Icons.event,
            size: 64,
            color: Colors.grey[400],
          ),
        ),
      );
    }
  }

  Widget _buildStatItem(IconData icon, String value, {Color? color}) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  void _shareEvent() {
    // Implémentez le partage ici
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Partager ${widget.evenement.titre}'),
        content: Text('Partager cet événement avec vos amis'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Modèle Dart correspondant à votre modèle Django
class Evenement {
  final String titre;
  final String description;
  final DateTime date;
  final String lieu;
  final String? image;
  final String? video;
  int vue;
  int lecture;
  int likes;

  Evenement({
    required this.titre,
    required this.description,
    required this.date,
    required this.lieu,
    this.image,
    this.video,
    this.vue = 0,
    this.lecture = 0,
    this.likes = 0,
  });

  @override
  String toString() {
    return '$titre - $lieu';
  }
}