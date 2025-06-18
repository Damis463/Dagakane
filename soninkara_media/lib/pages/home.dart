import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/rendering.dart';
import 'package:soninkara_media/pages/actualite_page.dart';
import 'package:soninkara_media/pages/contact.dart';
import 'package:soninkara_media/pages/debats.dart';
import 'package:soninkara_media/pages/divers_page.dart';
import 'package:soninkara_media/pages/evenement_page.dart';
import 'package:soninkara_media/pages/interview_page.dart';
import 'package:soninkara_media/pages/lives.dart';
import 'package:soninkara_media/pages/musique_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  int _selectedDrawerIndex = 0;
  bool _showAppBar = true;
  final ScrollController _scrollController = ScrollController();

  final Color primaryColor = const Color(0xFF1565C0); // bleu foncé
  final Color secondaryColor = const Color(0xFF1976D2);
  final Color accentColor = const Color(0xFF64B5F6); // bleu clair
  final Color backgroundColor = const Color(0xFFF0F2F5);
  final Color cardColor = Colors.white;
  final Color textColor = const Color(0xFF3B4A54);
  final Color subtitleColor = const Color(0xFF667781);

  final List<Map<String, dynamic>> menuItems = [
    {
      'title': 'Actualités',
      'icon': Icons.article_outlined,
      'activeIcon': Icons.article,
      'page': const ActualitePage(),
      'notifications': 6,
    },
    {
      'title': 'Divers',
      'icon': Icons.video_library_outlined,
      'activeIcon': Icons.video_library,
      'page': const VideoDiversPage(),
      'notifications': 3,
    },
    {
      'title': 'Musique',
      'icon': Icons.music_note_outlined,
      'activeIcon': Icons.music_note,
      'page':  MusiquePage(),
      'notifications': 2,
    },
  ];

  final List<Map<String, dynamic>> drawerItems = [
    {
      'title': 'Direct',
      'icon': Icons.live_tv_outlined,
      'activeIcon': Icons.live_tv,
      'page': const LivePage(),
      'notifications': 6,
    },
    {
      'title': 'Interviews',
      'icon': Icons.mic_outlined,
      'activeIcon': Icons.mic,
      'page': const InterviewPage(),
      'notifications': 0,
    },
    {
      'title': 'Événements',
      'icon': Icons.event_outlined,
      'activeIcon': Icons.event,
      'page': const EvenementPage(),
      'notifications': 0,
    },
    {
      'title': 'Débats',
      'icon': Icons.forum_outlined,
      'activeIcon': Icons.forum,
      'page': const DebatPage(),
      'notifications': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: menuItems.length, vsync: this)
      ..addListener(() {
        setState(() => _currentIndex = _tabController.index);
      });

    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;
      if (direction == ScrollDirection.reverse) {
        setState(() => _showAppBar = false);
      } else if (direction == ScrollDirection.forward) {
        setState(() => _showAppBar = true);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: _buildDrawer(),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [_buildSliverAppBar()];
        },
        body: TabBarView(
          controller: _tabController,
          children: menuItems
              .map<Widget>((item) => item['page'] as Widget)
              .toList(),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildWhatsAppLikeBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: true,
      snap: true,
      elevation: _showAppBar ? 4 : 0,
      expandedHeight: 100,
      collapsedHeight: 70,
      backgroundColor: primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: AnimatedOpacity(
          opacity: _showAppBar ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.9),
                ),
                padding: const EdgeInsets.all(6),
                child: Image.asset('images/logo.png', height: 30),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kayes Culture',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'La voix des racines',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {},
        ),
        _buildNotificationButton(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildNotificationButton() {
    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: 6, end: 6),
      badgeContent: const Text(
        '3',
        style: TextStyle(color: Colors.white, fontSize: 10),
      ),
      badgeStyle: badges.BadgeStyle(
        badgeColor: accentColor,
        padding: const EdgeInsets.all(5),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
      child: IconButton(
        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
        onPressed: () {},
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Remplacement de l'icône de profil par votre logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Image.asset('images/logo.png'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kayes Culture Média',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'info@kayesculture.com',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 20),
              children: [
                ...drawerItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _buildDrawerItem(item, index);
                }).toList(),
                ListTile(
                  leading: Icon(Icons.mail_outline, color: textColor),
                  title: Text(
                    'Nous contacter',
                    style: TextStyle(color: textColor),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: 8),
                Text('Version 1.0.0', style: TextStyle(color: subtitleColor)),
                const SizedBox(height: 4),
                Text(
                  '© 2023 Kayes Culture Média',
                  style: TextStyle(color: subtitleColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(Map<String, dynamic> item, int index) {
    final isSelected = _selectedDrawerIndex == index;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          isSelected ? item['activeIcon'] : item['icon'],
          color: isSelected ? primaryColor : textColor,
        ),
      ),
      title: Text(
        item['title'],
        style: TextStyle(
          color: isSelected ? primaryColor : textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: item['notifications'] > 0
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${item['notifications']}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          : null,
      onTap: () {
        setState(() => _selectedDrawerIndex = index);
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => item['page'] as Widget),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: accentColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.live_tv, color: Colors.white, size: 28),
      onPressed: () {
        final liveIndex = drawerItems.indexWhere(
          (item) => item['title'] == 'Direct',
        );
        if (liveIndex != -1) {
          setState(() => _selectedDrawerIndex = liveIndex);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => drawerItems[liveIndex]['page'] as Widget,
            ),
          );
        }
      },
    );
  }

  Widget _buildWhatsAppLikeBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        height:
            kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom,
        child: TabBar(
          controller: _tabController,
          indicatorColor: Colors.transparent,
          labelColor: primaryColor,
          unselectedLabelColor: subtitleColor,
          labelPadding: EdgeInsets.zero,
          tabs: menuItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = _currentIndex == index;

            return Tab(
              iconMargin: EdgeInsets.zero,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    badges.Badge(
                      position: badges.BadgePosition.topEnd(top: -8, end: -12),
                      showBadge: item['notifications'] > 0,
                      badgeContent: Text(
                        '${item['notifications']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                      badgeStyle: badges.BadgeStyle(
                        badgeColor: accentColor,
                        padding: const EdgeInsets.all(4),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        isSelected ? item['activeIcon'] : item['icon'],
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['title'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
