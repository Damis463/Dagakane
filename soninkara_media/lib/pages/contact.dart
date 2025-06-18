import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  String nom = '';
  String email = '';
  String message = '';

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Impossible d\'ouvrir $url');
    }
  }

  void _envoyer() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Traiter ici ou envoyer à l'API
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Message envoyé !')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nous contacter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: (value) =>
                        value!.isEmpty ? 'Entrez votre nom' : null,
                    onSaved: (value) => nom = value!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) =>
                        value!.contains('@') ? null : 'Email invalide',
                    onSaved: (value) => email = value!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Message'),
                    validator: (value) =>
                        value!.isEmpty ? 'Écrivez un message' : null,
                    onSaved: (value) => message = value!,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _envoyer,
                    icon: const Icon(Icons.send),
                    label: const Text('Envoyer'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Suivez-nous',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              children: [
                IconButton(
                  icon: const Icon(Icons.facebook, color: Colors.blue),
                  onPressed: () =>
                      _launchUrl('https://facebook.com/soninkaramedia'),
                ),
                IconButton(
                  icon: const Icon(Icons.video_collection, color: Colors.red),
                  onPressed: () =>
                      _launchUrl('https://youtube.com/soninkaramedia'),
                ),
                IconButton(
                  icon: const Icon(Icons.chat, color: Colors.green),
                  onPressed: () => _launchUrl('https://wa.me/223XXXXXXXX'),
                ),
                IconButton(
                  icon: const Icon(Icons.music_note, color: Colors.purple),
                  onPressed: () =>
                      _launchUrl('https://tiktok.com/@soninkaramedia'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
