import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const kBlue = Color(0xFF14307A);
const kGold = Color(0xFFC9A24B);
const kBg = Color(0xFFF7F8FC);

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

class LogoImage extends StatelessWidget {
  final double height;
  final String file;
  const LogoImage({super.key, this.height = 120, this.file = 'logo.png'});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/$file',
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

  static const _titles = ['Home', 'Sermons', 'Events', 'Give', 'Prayer'];
  final _pages = const [
    HomePage(),
    SermonsPage(),
    EventsPage(),
    GivePage(),
    PrayerPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        indicatorColor: kGold.withOpacity(0.35),
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.play_circle_outline), label: 'Sermons'),
          NavigationDestination(
              icon: Icon(Icons.event_outlined), label: 'Events'),
          NavigationDestination(
              icon: Icon(Icons.volunteer_activism_outlined), label: 'Give'),
          NavigationDestination(
              icon: Icon(Icons.front_hand_outlined), label: 'Prayer'),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const SectionCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kGold.withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: kBlue, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Center(child: LogoImage(height: 150)),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Healing for the broken. Grace for the journey.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: kBlue, fontStyle: FontStyle.italic, fontSize: 15),
          ),
        ),
        const SizedBox(height: 20),
        const SectionCard(
          title: 'Daily Devotional',
          child: Text(
            'Come to me, all you who are weary and burdened, and I will give you rest. (Matthew 11:28)\n\nEdit this text each day, or connect it to a server later.',
          ),
        ),
        const SectionCard(
          title: 'Announcements',
          child: Text('Sunday Service: 9:00 AM\nMidweek Prayer: Wednesday, 6:00 PM'),
        ),
        const SectionCard(
          title: 'Need counselling or prayer?',
          child: Text('Tap the Prayer tab to send us a request. We will pray with you.'),
        ),
      ],
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

  // TODO: replace with your real account details
  static const bank = 'Your Fidelity Bank Plc';
  static const accName = 'Graceway Healing Ministries';
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
              const Text('Bank: Fidelity Bank ),
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
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: kGold,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Online card payment (Paystack) coming soon')),
          ),
          child: const Text('Give online (coming soon)'),
        ),
      ],
    );
  }
}

class PrayerPage extends StatefulWidget {
  const PrayerPage({super.key});
  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> {
  final _name = TextEditingController();
  final _request = TextEditingController();
  bool _private = true;

  @override
  void dispose() {
    _name.dispose();
    _request.dispose();
    super.dispose();
  }

  void _submit() {
    if (_request.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write your prayer request')),
      );
      return;
    }
    // TODO: send to your backend (Firebase) so the prayer team receives it
    _name.clear();
    _request.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you. We are praying with you.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionCard(
          title: 'Share your prayer request',
          child: Text('Your request is handled with care and confidentiality.'),
        ),
        TextField(
          controller: _name,
          decoration: const InputDecoration(
            labelText: 'Your name (optional)',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _request,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Prayer request',
            alignLabelWithHint: true,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
        ),
        SwitchListTile(
          value: _private,
          activeColor: kBlue,
          title: const Text('Keep this request private'),
          onChanged: (v) => setState(() => _private = v),
        ),
        const SizedBox(height: 6),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: kBlue,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: _submit,
          child: const Text('Send request'),
        ),
      ],
    );
  }
}
