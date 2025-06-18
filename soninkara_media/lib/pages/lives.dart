import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  List<dynamic> liveStreams = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  final ScrollController _scrollController = ScrollController();
  int? _currentLiveIndex;

  @override
  void initState() {
    super.initState();
    _fetchLiveStreams();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchLiveStreams() async {
    const apiUrl = 'http://localhost:8000/api/lives/';

    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            liveStreams = data;
            isLoading = false;
            hasError = false;
            if (liveStreams.isNotEmpty) _currentLiveIndex = 0;
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
              'Impossible de charger les streams en direct. Veuillez réessayer.';
        });
      }
    }
  }

  Widget _getPlatformIcon(String platform) {
    switch (platform) {
      case 'youtube':
        return const FaIcon(FontAwesomeIcons.youtube, color: Colors.red);
      case 'facebook':
        return const FaIcon(FontAwesomeIcons.facebook, color: Colors.blue);
      case 'tiktok':
        return const FaIcon(FontAwesomeIcons.tiktok);
      default:
        return const Icon(Icons.live_tv);
    }
  }

  Widget _buildLiveItem(Map<String, dynamic> live, int index) {
    final titre = live['titre']?.toString() ?? 'Stream en direct';
    final description = live['description']?.toString() ?? '';
    final platform = live['platform']?.toString() ?? '';
    final url = live['url']?.toString() ?? '';
    final date = live['date']?.toString() ?? '';

    final formattedDate = date.isNotEmpty
        ? DateFormat(
            'EEEE d MMMM y à HH:mm',
            'fr_FR',
          ).format(DateTime.parse(date))
        : 'En direct maintenant';

    final isSelected = _currentLiveIndex == index;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _currentLiveIndex = index;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getPlatformIcon(platform),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      titre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
              if (description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ],
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Regarder maintenant'),
                onPressed: () async {
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLiveStreams,
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
                    onPressed: _fetchLiveStreams,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
          : liveStreams.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.live_tv, size: 60, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text(
                    'Aucun stream en direct',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _fetchLiveStreams,
                    child: const Text('Vérifier à nouveau'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                if (_currentLiveIndex != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_circle),
                      label: const Text('Lancer le stream sélectionné'),
                      onPressed: () async {
                        final current = liveStreams[_currentLiveIndex!];
                        final url = current['url'] ?? '';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Streams disponibles',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchLiveStreams,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: liveStreams.length,
                      itemBuilder: (context, index) {
                        return _buildLiveItem(liveStreams[index], index);
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
