import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

const kBlue = Color(0xFF14307A);
const kGold = Color(0xFFC9A24B);
const kBg = Color(0xFFF7F8FC);

// One link for prayer requests AND the daily devotional
const kScriptUrl = 'https://script.google.com/macros/s/AKfycbzbZwuhCyMDb8wjd-68L6C6MzIL36DqNV9QmEoiH_PLhIoAxsjaeDSkPP76dYNnMUiXcw/exec';

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
        const DailyGraceCard(),
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

  static const bank = 'Fidelity Bank';
  static const accName = 'Micheal Owowa';
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
              const Text('Bank: $bank'),
              const Text('Account name: $accName'),
              const Text('Temporary ministry account'),
              const Text('Account number: $accNumber',
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
  bool _sending = false;

  @override
  void dispose() {
    _name.dispose();
    _request.dispose();
    super.dispose();
  }

  void _say(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    if (_request.text.trim().isEmpty) {
      _say('Please write your prayer request');
      return;
    }
    setState(() => _sending = true);
    try {
      final res = await http.post(Uri.parse(kScriptUrl), body: {
        'name': _name.text.trim(),
        'request': _request.text.trim(),
        'private': _private.toString(),
      });
      if (!mounted) return;
      if (res.statusCode < 400) {
        _name.clear();
        _request.clear();
        _say('Thank you. We are praying with you.');
      } else {
        _say('Could not send. Please try again.');
      }
    } catch (_) {
      if (mounted) _say('Could not send. Check your internet and try again.');
    }
    if (mounted) setState(() => _sending = false);
  }

  Future<void> _joinWhatsApp() async {
    final ok = await launchUrl(
      Uri.parse('https://chat.whatsapp.com/Ij16QL4YLDh0Sp3xr50VY9'),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) _say('Could not open WhatsApp');
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
          onPressed: _sending ? null : _submit,
          child: Text(_sending ? 'Sending...' : 'Send request'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: kBlue,
            side: const BorderSide(color: kGold, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: _joinWhatsApp,
          icon: const Icon(Icons.groups_outlined),
          label: const Text('Join our WhatsApp family'),
        ),
      ],
    );
  }
}

class DailyGraceCard extends StatefulWidget {
  const DailyGraceCard({super.key});
  @override
  State<DailyGraceCard> createState() => _DailyGraceCardState();
}

class _DailyGraceCardState extends State<DailyGraceCard> {
  String title = 'Rest for the weary';
  String verse =
      'Come to me, all you who are weary and burdened, and I will give you rest. (Matthew 11:28)';
  String message = '';
  String prayer = '';
  bool loading = true;
  bool expanded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await http
          .get(Uri.parse(kScriptUrl))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final v = (data['verse'] ?? '').toString();
        if (v.isNotEmpty && mounted) {
          setState(() {
            title = (data['title'] ?? '').toString();
            verse = v;
            message = (data['message'] ?? '').toString();
            prayer = (data['prayer'] ?? '').toString();
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  Future<void> _share() async {
    final text =
        'DAILY GRACE\n\n$title\n\n$verse\n\n$message\n\nPrayer:\n$prayer\n\n- Graceway & Healing Ministries';
    await launchUrl(
      Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}'),
      mode: LaunchMode.externalApplication,
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          text,
          style: const TextStyle(
            color: kGold,
            fontSize: 12,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final long = message.length > 280;
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kGold.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: kBlue,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kGold, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/pastor.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: kGold,
                        alignment: Alignment.center,
                        child: const Text(
                          'MO',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAILY GRACE',
                        style: TextStyle(
                          color: kGold,
                          letterSpacing: 2,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Pst. Micheal Owowa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Lead Pastor, Graceway & Healing Ministries',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (loading) const LinearProgressIndicator(minHeight: 2),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: kBlue,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _label("TODAY'S WORD"),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: kBg,
                    border: Border(left: BorderSide(color: kGold, width: 3)),
                  ),
                  child: Text(
                    verse,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _label('MESSAGE'),
                  Text(
                    message,
                    maxLines: (long && !expanded) ? 7 : null,
                    overflow: (long && !expanded)
                        ? TextOverflow.ellipsis
                        : TextOverflow.visible,
                    style: const TextStyle(fontSize: 15, height: 1.55),
                  ),
                  if (long)
                    TextButton(
                      onPressed: () => setState(() => expanded = !expanded),
                      child: Text(expanded ? 'Show less' : 'Read full message'),
                    ),
                ],
                                if (prayer.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _label('PRAYER'),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kBlue.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      prayer,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.55,
                        color: kBlue,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _share,
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('Share on WhatsApp'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
 
