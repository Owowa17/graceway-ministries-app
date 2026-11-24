import 'dart:convert'; // ✅ Added for JSON decoding
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; // ✅ Added for fetching devotional
import 'helpers.dart';
import 'community.dart';

void main() => runApp(const GracewayApp());

class GracewayApp extends StatelessWidget {
  const GracewayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Graceway Healing Ministries',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kBlue,
          primary: kBlue,
          secondary: kGold,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kBlue,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ✅ FIXED: Path changed to 'assets/' and default file to 'icon.png'
class LogoImage extends StatelessWidget {
  final double height;
  final String file;
  const LogoImage({super.key, this.height = 120, this.file = 'icon.png'});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/$file',
      height: height,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.church, size: height * 0.6, color: kGold),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: LogoImage(height: 220)),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _titles = ['Home', 'Sermons', 'Events', 'Give', 'Community'];
  final _pages = const [
    HomePage(),
    SermonsPage(),
    EventsPage(),
    GivePage(),
    CommunityPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        indicatorColor: kGold.withValues(alpha: 0.35), // Fixed deprecation
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.play_circle_outline), label: 'Sermons'),
          NavigationDestination(icon: Icon(Icons.event_outlined), label: 'Events'),
          NavigationDestination(icon: Icon(Icons.volunteer_activism_outlined), label: 'Give'),
          NavigationDestination(icon: Icon(Icons.people_outline), label: 'Community'),
        ],
      ),
    );
  }
}

// ✅ FIXED: Turned into StatefulWidget to fetch from Google Script + Added Pastor Image
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _title = 'Daily Grace';
  String _verse = '';
  String _message = 'Loading today\'s devotional...';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDevotional();
  }

  Future<void> _fetchDevotional() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(Uri.parse('$kScriptUrl?action=get_devotional'))
          .timeout(const Duration(seconds: 15));
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          setState(() {
            _title = data['title'] ?? 'Daily Grace';
            _verse = data['verse'] ?? '';
            _message = data['message'] ?? 'No message today.';
          });
        }
      }
    } catch (e) {
      setState(() => _message = 'Could not load devotional. Check your internet.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchDevotional,
      color: kBlue,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // Logo
          const Center(child: LogoImage(height: 100)), 
          const SizedBox(height: 16),
          
          // Pastor Image & Welcome
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: kGold.withValues(alpha: 0.2),
              backgroundImage: const AssetImage('assets/pastor.png'), // ✅ Fixed path
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Pst. Michael Owowa',
              style: TextStyle(color: kBlue, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Center(
            child: Text(
              'Healing for the broken. Grace for the journey.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic, fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),

          // Dynamic Daily Devotional
          SectionCard(
            title: _title,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_verse.isNotEmpty) ...[
                  Text(
                    _verse,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kGold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (_loading)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: kGold),
                  ))
                else
                  Text(
                    _message,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
              ],
            ),
          ),

          // Announcements
          const SectionCard(
            title: 'Announcements',
            child: Text('Sunday Service: 9:00 AM\nMidweek Prayer: Wednesday, 6:00 PM'),
          ),
        ],
      ),
    );
  }
}

class SermonsPage extends StatelessWidget {
  const SermonsPage({super.key});

  static const _sermons = [
    ['Grace That Restores', 'Sunday Service'],
    ['Walking in Healing', 'Midweek Service'],
    ['Faith for the Journey', 'Sunday Service'],
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _sermons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => Card(
        color: Colors.white,
        elevation: 0,
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: kBlue,
            child: Icon(Icons.play_arrow, color: Colors.white),
          ),
          title: Text(_sermons[i][0],
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(_sermons[i][1]),
          trailing: const Icon(Icons.download_outlined, color: kGold),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Audio and video playback coming soon')),
          ),
        ),
      ),
    );
  }
}

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  static const _events = [
    ['Sunday Worship Service', 'Every Sunday, 9:00 AM'],
    ['Midweek Prayer Meeting', 'Every Wednesday, 6:00 PM'],
    ['Healing Night', 'Last Friday of the month, 7:00 PM'],
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final e in _events)
          SectionCard(
            title: e[0],
            child: Row(
              children: [
                const Icon(Icons.schedule, size: 18, color: kGold),
                const SizedBox(width: 8),
                Text(e[1]),
              ],
            ),
          ),
      ],
    );
  }
}

class GivePage extends StatelessWidget {
  const GivePage({super.key});

  static const accNumber = '6011920596';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionCard(
          title: 'Give with a cheerful heart',
          child: Text('Your tithes and offerings support the work of the ministry.'),
        ),
        SectionCard(
          title: 'Bank transfer',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bank: Fidelity Bank'), 
              const Text('Approved Temporary Account For The Ministries: Micheal Owowa'),
              const Text('Account Number: 6011920596',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: accNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account number copied')),
                  );
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy account number'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
