import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
Future<Map<String, dynamic>?> getJson(String query) async {
  try {
    final res = await http
        .get(Uri.parse('$kScriptUrl$query'))
        .timeout(const Duration(seconds: 20));
    final body = res.body.trimLeft();
    if (res.statusCode != 200 || !body.startsWith('{')) return null;
    return jsonDecode(body) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
}

class ShortsPage extends StatefulWidget {
  const ShortsPage({super.key});
  @override
  State<ShortsPage> createState() => _ShortsPageState();
}

class _ShortsPageState extends State<ShortsPage> {
  List<Map<String, dynamic>> items = [];
  bool loading = true;
  bool failed = false;
  int page = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      failed = false;
    });
    final data = await getJson('?action=shorts');
    if (!mounted) return;
    setState(() {
      failed = data == null;
      items = data == null
          ? []
          : ((data['items'] as List?) ?? [])
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (failed || items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                failed
                    ? 'Could not load videos. Check your internet.'
                    : 'No videos yet. Check back soon.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: kBlue),
                onPressed: _load,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: items.length,
      onPageChanged: (i) => setState(() => page = i),
      itemBuilder: (_, i) => ShortItem(item: items[i], active: i == page),
    );
  }
}

class ShortItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool active;
  const ShortItem({super.key, required this.item, required this.active});
  @override
  State<ShortItem> createState() => _ShortItemState();
}

class _ShortItemState extends State<ShortItem> {
  late final VideoPlayerController _c;
  bool _ready = false;
  bool _bad = false;

  @override
  void initState() {
    super.initState();
    _c = VideoPlayerController.networkUrl(
        Uri.parse(widget.item['url'].toString()));
    _c.setLooping(true);
    _c.initialize().then((_) {
      if (!mounted) return;
      setState(() => _ready = true);
      if (widget.active) _c.play();
    }).catchError((_) {
      if (mounted) setState(() => _bad = true);
    });
  }

  @override
  void didUpdateWidget(ShortItem old) {
    super.didUpdateWidget(old);
    if (!_ready) return;
    widget.active ? _c.play() : _c.pause();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!_ready) return;
    setState(() => _c.value.isPlaying ? _c.pause() : _c.play());
  }

  @override
  Widget build(BuildContext context) {
    final title = (widget.item['title'] ?? '').toString();
    final caption = (widget.item['caption'] ?? '').toString();
    final url = (widget.item['url'] ?? '').toString();
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_ready)
              Center(
                child: AspectRatio(
                  aspectRatio: _c.value.aspectRatio,
                  child: VideoPlayer(_c),
                ),
              )
            else
              Center(
                child: _bad
                    ? const Text('Video unavailable',
                        style: TextStyle(color: Colors.white70))
                    : const CircularProgressIndicator(color: kGold),
              ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: kGold,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(caption,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: kGold),
                    ),
                    onPressed: () => openUri(Uri.parse(
                        'https://wa.me/?text=${Uri.encodeComponent('$title\n$url')}')),
                    icon: const Icon(Icons.share),
                    label: const Text('Share on WhatsApp'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
