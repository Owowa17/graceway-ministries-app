import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

const kBlue = Color(0xFF14307A);
const kGold = Color(0xFFC9A24B);
const kBg = Color(0xFFF7F8FC);
const kRed = Color(0xFFB3261E);

// One link for prayers, devotionals, help requests and testimonies
const kScriptUrl = 'https://script.google.com/macros/s/AKfycbyccmvbK6vy-h-g5TPjvuAwKjlqJHgSr49wlJnuef6N06H8rVjVRQBzVWWUhQgaWYJ0/exec';

// Urgent help contacts.
// 112 is Nigeria's toll-free national emergency number.
const kEmergencyNumber = '112';

// Pastoral care line: use a ministry number, not a personal one.
// Everyone who installs the app can see it. Leave '' to hide the buttons.
// Examples: '08012345678' or '+2348012345678'
const kPastoralPhone = '08120174348'; // Your number integrated here

final String pastoralDial = kPastoralPhone.replaceAll(RegExp(r'[^0-9+]'), '');
final String pastoralWhatsApp = _toWhatsApp(pastoralDial);

String _toWhatsApp(String n) {
  final d = n.replaceAll(RegExp(r'\D'), '');
  if (d.isEmpty) return '';
  if (d.startsWith('234')) return d;
  if (d.startsWith('0')) return '234${d.substring(1)}';
  return d;
}

void main() => runApp(const GracewayApp());

// ---------- helpers ----------

void say(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

Future<bool> postToScript(Map<String, String> body) async {
  try {
    final res = await http
        .post(Uri.parse(kScriptUrl), body: body)
        .timeout(const Duration(seconds: 20));
    return res.statusCode < 400;
  } catch (_) {
    return false;
  }
}

Future<bool> openUri(Uri uri) async {
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

Future<void> callNumber(BuildContext context, String number) async {
  final ok = await openUri(Uri(scheme: 'tel', path: number));
  if (ok) return;
  await Clipboard.setData(ClipboardData(text: number));
  if (context.mounted) {
    say(context, 'Could not open the dialer. Number copied: $number');
  }
}

void showUrgentHelp(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (sheetContext) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Urgent help',
                style: TextStyle(
                  color: kRed,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'If you or someone near you is in immediate danger, call the emergency line now. It is toll-free, but it may not be active in every state yet.',
                style: TextStyle(fontSize: 15, height: 1.45),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: kRed,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => callNumber(sheetContext, kEmergencyNumber),
                icon: const Icon(Icons.call),
                label: const Text('Call emergency: $kEmergencyNumber'),
              ),
              if (pastoralDial.isNotEmpty) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => callNumber(sheetContext, pastoralDial),
                  icon: const Icon(Icons.support_agent),
                  label: const Text('Call our pastoral care line'),
                ),
              ],
              if (pastoralWhatsApp.isNotEmpty) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () =>
                      openUri(Uri.parse('https://wa.me/$pastoralWhatsApp')),
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('Message us on WhatsApp'),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'This app is not monitored around the clock. For other needs such as food, rent, school fees or counselling, use the Need Help form in the Community tab.',
                style: TextStyle(fontSize: 13, height: 1.45, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ---------- app ----------

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

  static const _titles = ['Home', 'Sermons', 'Community', 'Give', 'Prayer'];
  final _pages = const [
    HomePage(),
    SermonsPage(),
    CommunityPage(),
    GivePage(),
    PrayerPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        indicatorColor: kGold.withOpacity(0.35),
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.play_circle_outline), label: 'Sermons'),
          NavigationDestination(
              icon: Icon(Icons.groups_outlined), label: 'Community'),
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

// ---------- home ----------

class DirectCallCard extends StatelessWidget {
  const DirectCallCard({super.key});

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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: kBlue,
          child: Icon(Icons.phone_in_talk, color: Colors.white),
        ),
        title: const Text(
          'Need to talk or pray?',
          style: TextStyle(color: kBlue, fontWeight: FontWeight.w700),
        ),
        subtitle: const Text('Tap to call our pastoral care line'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: kGold),
        onTap: () => callNumber(context, pastoralDial), // Updated to use pastoralDial
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
        const DirectCallCard(),
        const SectionCard(
          title: 'Announcements',
          child: Text(
              'Sunday Service: 9:00 AM\nMidweek Prayer: Wednesday, 6:00 PM\nHealing Night: Last Friday of the month, 7:00 PM'),
        ),
        const SectionCard(
          title: 'Need counselling or prayer?',
          child: Text(
              'Tap the Prayer tab to send us a request, or open the Community tab to ask for help or share a testimony.'),
        ),
      ],
    );
  }
}

// ---------- sermons (placeholder) ----------

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

// ---------- community: Grace Wall + Need Help ----------

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: kBlue,
              unselectedLabelColor: Colors.black54,
              indicatorColor: kGold,
              tabs: [
                Tab(text: 'Grace Wall'),
                Tab(text: 'Need Help'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                GraceWallTab(),
                NeedHelpTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GraceWallTab extends StatefulWidget {
  const GraceWallTab({super.key});
  @override
  State<GraceWallTab> createState() => _GraceWallTabState();
}

class _GraceWallTabState extends State<GraceWallTab> {
  List<Map<String, dynamic>> items = [];
  bool loading = true;
  bool failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    bool bad = false;
    List<Map<String, dynamic>> next = [];
    try {
      final res = await http
          .get(Uri.parse('$kScriptUrl?action=testimonies'))
          .timeout(const Duration(seconds: 20));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final list = (data['items'] as List?) ?? [];
        next = list
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } else {
        bad = true;
      }
    } catch (_) {
      bad = true;
    }
    if (!mounted) return;
    setState(() {
      if (!bad) items = next;
      failed = bad;
      loading = false;
    });
  }

  void _share() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => const TestimonyForm(),
    );
  }

  Widget _card(Map<String, dynamic> t) {
    final name = (t['name'] ?? 'Anonymous').toString();
    final text = (t['text'] ?? '').toString();
    final date = (t['date'] ?? '').toString();
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kGold.withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: const TextStyle(fontSize: 15, height: 1.5)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.favorite, size: 14, color: kGold),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    date.isEmpty ? name : '$name  -  $date',
                    style: const TextStyle(
                      color: kBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: kBlue,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const SectionCard(
            title: 'Grace Wall',
            child: Text(
                'Read what God has done, and share your own story to encourage others.'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: kBlue,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _share,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Share your testimony'),
          ),
          const SizedBox(height: 14),
          if (loading && items.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
          if (failed && items.isEmpty)
            const SectionCard(
              title: 'Could not load',
              child: Text('Check your internet and pull down to try again.'),
            ),
          if (!loading && !failed && items.isEmpty)
            const SectionCard(
              title: 'Be the first',
              child: Text('No testimonies yet. Share what God has done for you.'),
            ),
          for (final t in items) _card(t),
        ],
      ),
    );
  }
}

class TestimonyForm extends StatefulWidget {
  const TestimonyForm({super.key});
  @override
  State<TestimonyForm> createState() => _TestimonyFormState();
}

class _TestimonyFormState extends State<TestimonyForm> {
  final _name = TextEditingController();
  final _text = TextEditingController();
  bool _showName = true;
  bool _sending = false;

  @override
  void dispose() {
    _name.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _text.text.trim();
    if (text.length < 15) {
      say(context, 'Please write a little more of your testimony');
      return;
    }
    setState(() => _sending = true);
    final ok = await postToScript({
      'type': 'testimony',
      'name': _name.text.trim(),
      'text': text,
      'showName': _showName.toString(),
    });
    if (!mounted) return;
    setState(() => _sending = false);
    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      Navigator.of(context).pop();
      messenger.showSnackBar(const SnackBar(
        content: Text('Thank you! Your testimony will appear after review.'),
      ));
    } else {
      messenger.showSnackBar(const SnackBar(
        content: Text('Could not send. Check your internet and try again.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share your testimony',
              style: TextStyle(
                color: kBlue,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Your name (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _text,
              maxLines: 6,
              maxLength: 600,
              decoration: const InputDecoration(
                labelText: 'What has God done for you?',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _showName,
              activeColor: kBlue,
                            title: const Text('Show my name'),
              onChanged: (v) => setState(() => _showName = v),
            ),
            const Text(
              'Testimonies are reviewed before they appear. Please do not include phone numbers, addresses or other private details.',
              style: TextStyle(fontSize: 12, height: 1.4, color: Colors.black54),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: kBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _sending ? null : _submit,
                child: Text(_sending ? 'Sending...' : 'Submit testimony'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NeedHelpTab extends StatefulWidget {
  const NeedHelpTab({super.key});
  @override
  State<NeedHelpTab> createState() => _NeedHelpTabState();
}

class _NeedHelpTabState extends State<NeedHelpTab> {
  static const _needs = ['Food', 'Rent', 'School fees', 'Counselling', 'Other'];

  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _details = TextEditingController();
  String? _need;
  bool _urgent = false;
  bool _sending = false;

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_need == null) {
      say(context, 'Please choose what you need help with');
      return;
    }
    if (_contact.text.trim().isEmpty) {
      say(context, 'Please add a phone or WhatsApp number so we can reach you');
      return;
    }
    if (_details.text.trim().isEmpty) {
      say(context, 'Please tell us a little about your need');
      return;
    }
    setState(() => _sending = true);
    final ok = await postToScript({
      'type': 'help',
      'name': _name.text.trim(),
      'contact': _contact.text.trim(),
      'need': _need!,
      'details': _details.text.trim(),
      'urgent': _urgent.toString(),
    });
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) {
      _name.clear();
      _contact.clear();
      _details.clear();
      setState(() {
        _need = null;
        _urgent = false;
      });
      say(context, 'Request received. Our care team will reach out to you.');
    } else {
      say(context, 'Could not send. Check your internet and try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: kRed,
            side: const BorderSide(color: kRed, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () => showUrgentHelp(context),
          icon: const Icon(Icons.health_and_safety_outlined),
          label: const Text('Urgent help and emergency numbers'),
        ),
        const SizedBox(height: 14),
        const SectionCard(
          title: 'Ask for help',
          child: Text(
              'Tell us what you need. Only our care team sees this. Please do not share bank details or ID numbers.'),
        ),
        const Text(
          'What do you need help with?',
          style: TextStyle(color: kBlue, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final n in _needs)
              ChoiceChip(
                label: Text(n),
                selected: _need == n,
                selectedColor: kGold.withOpacity(0.35),
                onSelected: (v) => setState(() => _need = v ? n : null),
              ),
          ],
        ),
        const SizedBox(height: 14),
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
          controller: _contact,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone or WhatsApp number',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _details,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Tell us about your need',
            alignLabelWithHint: true,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _urgent,
          activeColor: kRed,
          title: const Text('This is urgent'),
          onChanged: (v) => setState(() => _urgent = v),
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
      ],
    );
  }
}

// ---------- give ----------

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

// ---------- prayer ----------

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

  Future<void> _submit() async {
    if (_request.text.trim().isEmpty) {
      say(context, 'Please write your prayer request');
      return;
    }
    setState(() => _sending = true);
    final ok = await postToScript({
      'type': 'prayer',
      'name': _name.text.trim(),
      'request': _request.text.trim(),
      'private': _private.toString(),
    });
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) {
      _name.clear();
      _request.clear();
      say(context, 'Thank you. We are praying with you.');
    } else {
      say(context, 'Could not send. Check your internet and try again.');
    }
  }

  Future<void> _joinWhatsApp() async {
    final ok = await openUri(
        Uri.parse('https://chat.whatsapp.com/Ij16QL4YLDh0Sp3xr50VY9'));
    if (!ok && mounted) say(context, 'Could not open WhatsApp');
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

// ---------- daily devotional ----------

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
    await openUri(Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}'));
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
              
