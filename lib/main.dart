import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

const kBlue = Color(0xFF14307A);
const kGold = Color(0xFFC9A24B);
const kBg = Color(0xFFF7F8FC);
const kRed = Color(0xFFB3261E);

// One link for prayers, devotionals, help requests and testimonies
const kScriptUrl = 'https://script.google.com/macros/s/AKfycbyccmvbK6vy-h-g5TPjvuAwKjlqJHgSr49wlJnuef6N06H8rVjVRQBzVWWUhQgaWYJ0/exec';

// Urgent help contacts.
// 112 is Nigeria's toll-free national emergency number.
// Add your pastoral care line below (leave '' to hide the buttons).
const kEmergencyNumber = '112';

// Pastoral care line: use a ministry number, not a personal one.
// Everyone who installs the app can see it. Leave '' to hide the buttons.
// Examples: '08012345678' or '+2348012345678'
const kPastoralPhone = '';

final String pastoralDial = kPastoralPhone.replaceAll(RegExp(r'[^0-9+]'), '');
final String pastoralWhatsApp = _toWhatsApp(pastoralDial);

String _toWhatsApp(String n) {
  final d = n.replaceAll(RegExp(r'\D'), '');
  if (d.isEmpty) return '';
  if (d.startsWith('234')) return d;
  if (d.startsWith('0')) return '234${d.substring(1)}';
  return d;
}

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
                  onPressed: () => openUri(Uri.parse(
                      'https://wa.me/$pastoralWhatsApp?text=Hello%2C%20I%20need%20pastoral%20care.')),
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

class HelpBanner extends StatelessWidget {
  const HelpBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFDECEA),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kRed.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.health_and_safety_outlined, color: kRed, size: 30),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need help now?',
                    style: TextStyle(
                      color: kRed,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Emergency and pastoral contacts',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: kRed),
              onPressed: () => showUrgentHelp(context),
              child: const Text('Urgent help'),
            ),
          ],
        ),
      ),
    );
  }
}
