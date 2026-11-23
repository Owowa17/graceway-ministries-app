import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// ============================================================
//  CONSTANTS
// ============================================================

const kBlue = Color(0xFF14307A);
const kGold = Color(0xFFC9A24B);
const kBg = Color(0xFFF7F8FC);
const kRed = Color(0xFFB3261E);

// Your Ministry App Script
const kScriptUrl =
    'https://script.google.com/macros/s/AKfycbyzT0UsnzdTGVH0xbxNWgee2PhHxjGEmmY-UdUMPmR3hTc1DC8RJpWYHLCjIf3myeDz/exec';

// Note: If this is the same URL as above, you can just use kScriptUrl. 
const kVideoBotUrl = kScriptUrl; 

const kEmergencyNumber = '112';
const kPastoralPhone = '08120174348';

final String pastoralDial = kPastoralPhone.replaceAll(RegExp(r'[^0-9+]'), '');
final String pastoralWhatsApp = _toWhatsApp(pastoralDial);

String _toWhatsApp(String n) {
  final d = n.replaceAll(RegExp(r'\D'), '');
  if (d.isEmpty) return '';
  if (d.startsWith('234')) return d;
  if (d.startsWith('0')) return '234${d.substring(1)}';
  return d;
}

// ============================================================
//  HELPERS
// ============================================================

// ✅ FIXED: Returns a bool so the UI can react to failures
Future<bool> queueVideoForGeneration(String title, String text) async {
  try {
    final response = await http.post(
      Uri.parse(kVideoBotUrl),
      body: {
        'type': 'generate_video',
        'title': title,
        'text': text,
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        debugPrint("✅ Video queued successfully!");
        return true;
      }
    }
  } catch (e) {
    debugPrint("❌ Error queueing video: $e");
  }
  return false;
}

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

// ============================================================
//  URGENT HELP SHEET
// ============================================================

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
                  onPressed: () => openUri(Uri.parse(
                      'https://wa.me/$pastoralWhatsApp?text=Hello%2C%20I%20need%20pastoral%20care.')),
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('Message us on WhatsApp'),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'This app is not monitored around the clock. For other needs such as food, rent, school fees or counselling, use the Need Help form in the Community tab.',
                style: TextStyle(
                    fontSize: 13, height: 1.45, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ============================================================
//  SECTION CARD
// ============================================================

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
                    color: kBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

// ============================================================
//  COMMUNITY — Grace Wall + Need Help
// ============================================================

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
      // ✅ FIXED: Safely add query parameter using Uri.replace
      final uri = Uri.parse(kScriptUrl).replace(queryParameters: {'action': 'testimonies'});
      
      final res = await http
          .get(uri)
          .timeout(const Duration(seconds: 20));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final list = (data['items'] as List?) ?? [];
        next = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
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
                    date.isEmpty ? name : '$name  -  $date',
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
              child:
                  Text('No testimonies yet. Share what God has done for you.'),
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
              style: TextStyle(
                  fontSize: 12, height: 1.4, color: Colors.black54),
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
        
                   // ✅ FIXED: Completed the cut-off section
        
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: kBlue,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _sending ? null : _submit,
            child: Text(_sending ? 'Sending...' : 'Submit Request'),
          ),
        ),
        const SizedBox(height: 20), // Extra padding for bottom scroll
      ],
    );
  }
}
