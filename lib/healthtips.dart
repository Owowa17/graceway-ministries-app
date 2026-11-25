import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Daily Health Tip card for the Home screen.
// Self-contained: it does not depend on any other file in the app.
// Usage: add  import 'health_tips.dart';  at the top of main.dart,
// then place  const HealthTipCard(),  in the Home page list.

const Color _tipBlue = Color(0xFF14307A);
const Color _tipGold = Color(0xFFC9A24B);
const String _appLink = 'https://owowa17.github.io/graceway-ministries-app/';

class _Tip {
  final String category;
  final String text;
  final String? verse;
  const _Tip(this.category, this.text, [this.verse]);
}

const List<_Tip> _tips = [
  _Tip('Water',
      'Start your day with a glass of water and keep sipping through the day. Enough water supports your energy, mood and digestion.'),
  _Tip('Sleep',
      'Most adults need about 7 to 9 hours of sleep. Keep a regular bedtime and put your phone away 30 minutes before you sleep.'),
  _Tip('Movement',
      'Aim for about 30 minutes of walking or other moderate activity on most days. Three short 10-minute walks count too.'),
  _Tip('Hygiene',
      'Wash your hands with soap and clean water before eating and after using the toilet. It prevents many common infections.'),
  _Tip('Food',
      'Fill half your plate with vegetables and fruits. Beans, fish, eggs and whole grains are affordable sources of protein and fibre.'),
  _Tip('Food',
      'Cut back on sugary drinks. Water, fresh fruit, or zobo with little sugar are better choices.'),
  _Tip('Heart',
      'Go easy on salt, seasoning cubes and salty snacks. Too much salt can raise your blood pressure over time.'),
  _Tip('Check-ups',
      'Have your blood pressure checked regularly, even if you feel fine. High blood pressure often has no warning signs.'),
  _Tip('Light',
      'Spend a few minutes outdoors in the morning light. It can lift your mood and help your sleep rhythm.'),
  _Tip('Mind',
      'Name what you are feeling and tell one trusted person. Carrying stress alone makes it heavier.'),
  _Tip('Joy',
      'Laugh today. Joy is good for the heart and the spirit.',
      'Proverbs 17:22 - A merry heart doeth good like a medicine.'),
  _Tip('Calm',
      'When stress rises, breathe in slowly for four counts and out for six. Repeat five times.'),
  _Tip('Prevention',
      'Sleep under a treated mosquito net and clear stagnant water around your home to lower your risk of malaria.'),
  _Tip('Food safety',
      'Wash fruits and vegetables, cook meat and fish thoroughly, and keep food covered to avoid stomach infections.'),
  _Tip('Movement',
      'If you sit for long periods, stand up and stretch every hour. Your back and circulation will thank you.'),
  _Tip('Eyes',
      'Rest your eyes. Every 20 minutes, look at something far away for 20 seconds.'),
  _Tip('Teeth',
      'Brush your teeth twice a day and visit a dentist at least once a year.'),
  _Tip('Fasting',
      'If you fast, drink water if you are able and break your fast gently. If you are sick, pregnant or on medication, ask your doctor first.'),
  _Tip('Medicine',
      'Take prescribed medicine exactly as directed and complete the course. Never share your medication with others.'),
  _Tip('Food',
      'Eat a fruit every day. Oranges, pawpaw, banana, watermelon and mango are all good choices.'),
  _Tip('Habits',
      'Avoid smoking and limit alcohol. Your body begins to benefit soon after you cut back.'),
  _Tip('Rest',
      'Take one proper rest day each week. Your body and mind need rest to recover.'),
  _Tip('Gratitude',
      'Write down three things you are grateful for tonight. Gratitude can lift your mood and help you sleep.'),
  _Tip('Relationships',
      'Call a friend or family member today. Good relationships are good for your health.'),
  _Tip('Food',
      'Eat slowly and stop when you are comfortably full.'),
  _Tip('Know your numbers',
      'Ask your clinic about checking blood pressure, blood sugar and weight, especially if diabetes or hypertension run in your family.'),
  _Tip('Snacks',
      'Choose groundnuts, fruit or boiled corn instead of chips and sweets when you want a snack.'),
  _Tip('Movement',
      'Do 10 minutes of simple exercise at home today, such as squats, stretching or a brisk walk around the compound.'),
  _Tip('Sleep',
      'Rest is a gift. Do not feel guilty about sleeping well.',
      'Psalm 127:2 - for so he giveth his beloved sleep.'),
  _Tip('Whole person',
      'Care for your body, mind and spirit together.',
      '3 John 1:2 - Beloved, I wish above all things that thou mayest prosper and be in health, even as thy soul prospereth.'),
];

class HealthTipCard extends StatefulWidget {
  const HealthTipCard({super.key});

  @override
  State<HealthTipCard> createState() => _HealthTipCardState();
}

class _HealthTipCardState extends State<HealthTipCard> {
  late int _index;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    _index = dayOfYear % _tips.length;
  }

  void _next() {
    setState(() => _index = (_index + 1) % _tips.length);
  }

  Future<void> _share(_Tip tip) async {
    final message = 'Daily Health Tip: ${tip.text}\n\n'
        '- Graceway Healing Ministries\n'
        'Get the free app: $_appLink';
    final uri =
        Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // If WhatsApp cannot open, do nothing.
    }
  }

  @override
  Widget build(BuildContext context) {
    final tip = _tips[_index];
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _tipGold.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite_outline, color: _tipGold, size: 22),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Daily Health Tip',
                    style: TextStyle(
                      color: _tipBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _tipGold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tip.category,
                    style: const TextStyle(
                      color: _tipBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              tip.text,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            if (tip.verse != null) ...[
              const SizedBox(height: 8),
              Text(
                tip.verse!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  fontStyle: FontStyle.italic,
                  color: _tipBlue,
                ),
              ),
            ],
            const SizedBox(height: 10),
            const Text(
              'General wellness advice, not medical advice. See a doctor or nurse about any health concern.',
              style: TextStyle(fontSize: 12, height: 1.4, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _share(tip),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share'),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _next,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Next tip'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
