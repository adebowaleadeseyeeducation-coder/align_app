import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────
// Extracted directly from the Align logo
const kBrand = Color(0xFF00897B); // bold jewel teal — loud and confident
const kBrandDark = Color(0xFF00695C); // deep teal for pressed/dark states
const kBrandLight = Color(0xFFD6F5F0); // light teal tint for card fills
const kBackground = Color(0xFFF0F7F6); // soft teal-white — warmer and deeper
const kSurface = Color(0xFFFFFFFF);
const kBorder = Color(0xFFBEE3DC); // teal-tinted border
const kTextPrimary = Color(0xFF0A1F1D); // near-black with teal undertone
const kTextSub = Color(0xFF4A7A74); // muted teal-grey
const kScoreGreen = Color(0xFF00897B); // matches brand for high scores
const kScoreAmber = Color(0xFFE09A2B); // warm amber
const kScoreRed = Color(0xFFD94F3D); // warm red
const kPremiumGold = Color(0xFFC9A84C); // gold for premium

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class AlignCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const AlignCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SectionHeading extends StatelessWidget {
  final String text;
  const SectionHeading(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: kTextPrimary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class AlignButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outline;
  final IconData? icon;

  const AlignButton({
    super.key,
    required this.label,
    this.onPressed,
    this.outline = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final content = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 19),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          )
        : Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));

    if (outline) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: kBrand,
          side: const BorderSide(color: kBrand, width: 1.8),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: content,
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: kBrand,
        foregroundColor: kSurface,
        elevation: 2,
        shadowColor: kBrand.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: content,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APP ROOT
// ─────────────────────────────────────────────────────────────────────────────
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlignApp());
}

class AlignApp extends StatelessWidget {
  const AlignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Align',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kBrand),
        scaffoldBackgroundColor: kBackground,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: kSurface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: kTextPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: IconThemeData(color: kTextPrimary),
        ),
      ),
      home: const OnboardingPage(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ONBOARDING
// ─────────────────────────────────────────────────────────────────────────────
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // ── LOGO ───────────────────────────────────────────────────
              Center(
                child: Image.asset(
                  'assets/images/Align-Logo.png',
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Understand how well your relationship\nis truly aligned — across every dimension that matters.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, color: kTextSub, height: 1.5),
              ),
              const Spacer(),
              const AlignCard(
                color: kBrandLight,
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: kTextSub),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Align is a self-reflection tool. It is not a substitute '
                        'for professional relationship counselling or therapy. '
                        'If you are experiencing serious difficulties, please '
                        'seek guidance from a qualified professional.',
                        style: TextStyle(
                            fontSize: 12.5, color: kTextSub, height: 1.55),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AlignButton(
                  label: 'Start Assessment',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LensSelectionPage()),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LENS
// ─────────────────────────────────────────────────────────────────────────────
enum Lens { universal, feminine, masculine }

const Map<Lens, String> lensDescriptions = {
  Lens.universal:
      'A balanced view of the relationship from a shared perspective.',
  Lens.feminine:
      'Explores emotional connection, nurturing, and relational depth.',
  Lens.masculine: 'Focuses on purpose, stability, leadership, and provision.',
};

const Map<Lens, IconData> lensIcons = {
  Lens.universal: Icons.balance_rounded,
  Lens.feminine: Icons.favorite_border_rounded,
  Lens.masculine: Icons.shield_outlined,
};

class LensSelectionPage extends StatelessWidget {
  const LensSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/Align-Logo.png',
                height: 30, fit: BoxFit.contain),
            const SizedBox(width: 8),
            const Text('Align',
                style: TextStyle(
                    color: kBrand, fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose your lens',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your lens shapes how questions and insights\nare framed for you.',
                style: TextStyle(fontSize: 14, color: kTextSub, height: 1.5),
              ),
              const SizedBox(height: 32),
              _lensCard(context, 'Universal', Lens.universal),
              const SizedBox(height: 14),
              _lensCard(context, 'Feminine', Lens.feminine),
              const SizedBox(height: 14),
              _lensCard(context, 'Masculine', Lens.masculine),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lensCard(BuildContext context, String label, Lens lens) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AssessmentPage(lens: lens)),
      ),
      child: AlignCard(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: kBrand.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(lensIcons[lens]!, color: kBrand, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lensDescriptions[lens]!,
                    style: const TextStyle(fontSize: 13, color: kTextSub),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: kTextSub),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PILLARS & LENS DATA
// ─────────────────────────────────────────────────────────────────────────────
const List<String> pillars = [
  'Trust',
  'Respect',
  'Emotional Support',
  'Shared Values',
  'Communication',
  'Physical Intimacy',
  'Future Alignment',
];

const Map<Lens, List<String>> pillarHints = {
  Lens.universal: [
    'Do you feel safe being fully honest with each other?',
    'Do you treat each other with consistent dignity?',
    'Are you there for each other during hard times?',
    'Do your core values and life priorities align?',
    'Can you talk openly without fear of judgement?',
    'Is physical connection present and mutually fulfilling?',
    'Do you share the same vision for the future?',
  ],
  Lens.feminine: [
    'Do you feel emotionally safe and unjudged?',
    'Do you feel heard, valued, and appreciated?',
    'Does your partner show up when you are vulnerable?',
    'Do you feel spiritually and emotionally compatible?',
    'Does your partner listen deeply, not just respond?',
    'Do you feel desired and emotionally connected physically?',
    'Does your partner support your personal growth and dreams?',
  ],
  Lens.masculine: [
    'Does your partner have your back unconditionally?',
    'Are you respected as a man in this relationship?',
    'Does your partner support you without undermining you?',
    'Do you share the same standards and principles?',
    'Can you speak directly without things escalating?',
    'Is physical intimacy consistent and mutually initiated?',
    'Are you both building toward the same life goals?',
  ],
};

const Map<Lens, List<String>> lensOverallInsights = {
  Lens.universal: [
    'This relationship is strongly aligned across all dimensions.',
    'This relationship is healthy but has areas worth nurturing.',
    'Alignment is uneven — intentional effort will make a difference.',
    'This relationship faces serious structural risks that need attention.',
  ],
  Lens.feminine: [
    'You feel deeply seen, valued, and emotionally secure in this relationship.',
    'The emotional foundation is present but some needs may be going unmet.',
    'There are emotional gaps that, if left unaddressed, may grow over time.',
    'Your emotional and relational needs are significantly underserved here.',
  ],
  Lens.masculine: [
    'This relationship gives you a solid foundation of respect and direction.',
    'The relationship is functional but may lack the depth of mutual respect.',
    'Key pillars of respect or purpose feel unstable — worth addressing directly.',
    'The relationship lacks the structure and respect needed for long-term strength.',
  ],
};

// ─────────────────────────────────────────────────────────────────────────────
// ASSESSMENT
// ─────────────────────────────────────────────────────────────────────────────
class AssessmentPage extends StatefulWidget {
  final Lens lens;
  const AssessmentPage({super.key, required this.lens});

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  final List<double> scores = List.filled(7, 0);
  final Set<int> touched = {};

  Color _scoreColor(double score) {
    if (score >= 7) return kScoreGreen;
    if (score >= 4) return kScoreAmber;
    return kScoreRed;
  }

  @override
  Widget build(BuildContext context) {
    final hints = pillarHints[widget.lens]!;
    final progress = touched.isEmpty ? 0.0 : touched.length / pillars.length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/Align-Logo.png',
                height: 30, fit: BoxFit.contain),
            const SizedBox(width: 8),
            const Text('Align',
                style: TextStyle(
                    color: kBrand, fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: kBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(kBrand),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: pillars.length,
        itemBuilder: (context, i) {
          final isTouched = touched.contains(i);
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: AlignCard(
              color: isTouched ? kSurface : const Color(0xFFFBFAF7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pillars[i],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: kTextPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isTouched
                              ? _scoreColor(scores[i]).withValues(alpha: 0.12)
                              : kBorder,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isTouched ? scores[i].round().toString() : '—',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color:
                                isTouched ? _scoreColor(scores[i]) : kTextSub,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hints[i],
                    style: const TextStyle(
                        fontSize: 13, color: kTextSub, height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor:
                          isTouched ? _scoreColor(scores[i]) : kTextSub,
                      thumbColor: isTouched ? _scoreColor(scores[i]) : kTextSub,
                      inactiveTrackColor: kBorder,
                      overlayColor: kBrand.withValues(alpha: 0.08),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: scores[i],
                      min: 0,
                      max: 10,
                      divisions: 10,
                      label: scores[i].round().toString(),
                      onChanged: (v) {
                        setState(() {
                          scores[i] = v;
                          touched.add(i);
                        });
                      },
                    ),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0  Not at all',
                          style: TextStyle(fontSize: 11, color: kTextSub)),
                      Text('10  Absolutely',
                          style: TextStyle(fontSize: 11, color: kTextSub)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: kBackground,
          border: Border(top: BorderSide(color: kBorder)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (touched.length < pillars.length)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  touched.isEmpty
                      ? 'Rate each pillar to get accurate results'
                      : '${pillars.length - touched.length} pillar${pillars.length - touched.length == 1 ? '' : 's'} unrated — unrated pillars score as 0',
                  style: const TextStyle(fontSize: 12, color: kTextSub),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: AlignButton(
                label: touched.length == pillars.length
                    ? 'See My Results'
                    : 'Continue with Current Scores',
                onPressed: () {
                  final total = scores.reduce((a, b) => a + b);
                  final percentage = (total / 70) * 100;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResultsPage(
                        percentage: percentage,
                        scores: scores,
                        lens: widget.lens,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INSIGHT ENGINE
// ─────────────────────────────────────────────────────────────────────────────
class InsightEngine {
  static String overall(double score, Lens lens) {
    final insights = lensOverallInsights[lens]!;
    if (score >= 85) return insights[0];
    if (score >= 70) return insights[1];
    if (score >= 55) return insights[2];
    return insights[3];
  }

  static String pillar(String name, double value) {
    if (value >= 8) return '$name is a strong pillar of this relationship.';
    if (value >= 6) return '$name is present but could be more consistent.';
    if (value >= 4) return '$name is unstable and deserves attention.';
    return '$name is critically weak and needs immediate focus.';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RADAR CHART
// ─────────────────────────────────────────────────────────────────────────────
class PillarRadarChart extends StatelessWidget {
  final List<double> scores;
  const PillarRadarChart({super.key, required this.scores});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.circle,
          tickCount: 5,
          radarBorderData: const BorderSide(color: kBorder),
          gridBorderData: const BorderSide(color: kBorder),
          getTitle: (index, angle) =>
              RadarChartTitle(text: pillars[index], angle: angle),
          dataSets: [
            RadarDataSet(
              dataEntries: scores.map((e) => RadarEntry(value: e)).toList(),
              borderColor: kBrand,
              fillColor: kBrand.withValues(alpha: 0.15),
              borderWidth: 2.5,
              entryRadius: 4,
            ),
          ],
          tickBorderData: const BorderSide(color: kBorder, width: 1),
          titleTextStyle: const TextStyle(fontSize: 11, color: kTextSub),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PILLAR BAR CHART
// ─────────────────────────────────────────────────────────────────────────────
Widget pillarAuthorityChart(List<double> scores) {
  return Column(
    children: List.generate(pillars.length, (i) {
      final score = scores[i];
      final color = score >= 7
          ? kScoreGreen
          : score >= 4
              ? kScoreAmber
              : kScoreRed;

      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(pillars[i],
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: kTextPrimary)),
                Text(
                  score.toStringAsFixed(0),
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: color),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: score / 10,
                minHeight: 8,
                backgroundColor: kBorder,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      );
    }),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// RESULTS PAGE
// ─────────────────────────────────────────────────────────────────────────────
class ResultsPage extends StatefulWidget {
  final double percentage;
  final List<double> scores;
  final Lens lens;

  const ResultsPage({
    super.key,
    required this.percentage,
    required this.scores,
    required this.lens,
  });

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  bool isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadPremium();
  }

  Future<void> _loadPremium() async {
    if (kDebugMode) {
      setState(() => isPremium = true);
      return;
    }
    isPremium = await PremiumService.isPremium();
    setState(() {});
  }

  String get grade {
    final p = widget.percentage;
    if (p >= 90) return 'A';
    if (p >= 80) return 'B';
    if (p >= 70) return 'C';
    if (p >= 60) return 'D';
    return 'F';
  }

  Color get gradeColor {
    final p = widget.percentage;
    if (p >= 70) return kScoreGreen;
    if (p >= 50) return kScoreAmber;
    return kScoreRed;
  }

  String get lensLabel {
    switch (widget.lens) {
      case Lens.feminine:
        return 'Feminine Lens';
      case Lens.masculine:
        return 'Masculine Lens';
      case Lens.universal:
        return 'Universal Lens';
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxScore = widget.scores.reduce((a, b) => a > b ? a : b);
    final minScore = widget.scores.reduce((a, b) => a < b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/Align-Logo.png',
                height: 30, fit: BoxFit.contain),
            const SizedBox(width: 8),
            const Text('Align',
                style: TextStyle(
                    color: kBrand, fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // ── SCORE HERO CARD ─────────────────────────────────────────
          AlignCard(
            color: gradeColor == kScoreGreen
                ? kBrandLight
                : gradeColor.withValues(alpha: 0.06),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: gradeColor,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        InsightEngine.overall(widget.percentage, widget.lens),
                        style: const TextStyle(
                            fontSize: 14, color: kTextSub, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: gradeColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: gradeColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          grade,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: kSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(lensLabel,
                        style: const TextStyle(fontSize: 11, color: kTextSub)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── KEY OBSERVATIONS ────────────────────────────────────────
          AlignCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeading('Key Observations'),
                _observationRow(
                  Icons.arrow_upward_rounded,
                  kScoreGreen,
                  InsightEngine.pillar(
                    pillars[widget.scores.indexOf(maxScore)],
                    maxScore,
                  ),
                ),
                const SizedBox(height: 10),
                _observationRow(
                  Icons.arrow_downward_rounded,
                  kScoreRed,
                  InsightEngine.pillar(
                    pillars[widget.scores.indexOf(minScore)],
                    minScore,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── PREMIUM CONTENT ─────────────────────────────────────────
          if (isPremium) ...[
            AlignCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeading('Relationship Structure Map'),
                  PillarRadarChart(scores: widget.scores),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AlignCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeading('Alignment Distribution'),
                  pillarAuthorityChart(widget.scores),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AlignCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeading('Pillar Stability Overview'),
                  ...PremiumInsightEngine.buildPillarStability(widget.scores),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kBrand.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      PremiumInsightEngine.renderInsights(widget.scores),
                      style: const TextStyle(
                          fontSize: 14, color: kBrandDark, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // ── PREMIUM LOCK CARD (free users in production) ─────────────
          if (!isPremium && !kDebugMode)
            Stack(
              children: [
                AlignCard(
                  color: const Color(0xFFFDF9F0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kPremiumGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: kPremiumGold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Unlock your full analysis',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Get the radar map, alignment distribution, pillar stability '
                        'ratings, and a full structural insight into your relationship.',
                        style: TextStyle(
                            fontSize: 13, color: kTextSub, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPremiumGold,
                            foregroundColor: kSurface,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            // ignore: todo
                            // TODO(payments): Replace with RevenueCat purchase before release
                            await PremiumService.unlockPremium();
                            setState(() => isPremium = true);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Premium unlocked! 🎉'),
                                  backgroundColor: kBrandDark,
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Unlock Premium',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Icon(Icons.lock_outline_rounded,
                      color: kPremiumGold.withValues(alpha: 0.5), size: 22),
                ),
              ],
            ),

          if (!isPremium && !kDebugMode) const SizedBox(height: 14),

          // ── SHARE ────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: AlignButton(
              label: 'Share My Result',
              icon: Icons.share_rounded,
              onPressed: () {
                SharePlus.instance.share(
                  ShareParams(
                    text: 'I scored ${widget.percentage.toStringAsFixed(0)}% '
                        '(Grade $grade) on Align — $lensLabel. '
                        'How aligned is your relationship?',
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _observationRow(IconData icon, Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style:
                const TextStyle(fontSize: 14, color: kTextPrimary, height: 1.4),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM INSIGHT ENGINE
// ─────────────────────────────────────────────────────────────────────────────
class PremiumInsightEngine {
  static String renderInsights(List<double> scores) {
    final weak = scores.where((s) => s <= 4).length;
    final strong = scores.where((s) => s >= 8).length;

    if (weak >= 3) {
      return 'This relationship shows multiple instability points that may '
          'create long-term structural risk. These areas deserve honest, '
          'direct attention.';
    }
    if (strong >= 4) {
      return 'This relationship is structurally reinforced by several strong '
          'pillars. Protect these strengths and intentionally build on them.';
    }
    return 'This relationship shows mixed structural signals. With intentional '
        'effort on the weaker pillars, alignment can improve significantly.';
  }

  static List<Widget> buildPillarStability(List<double> scores) {
    return List.generate(scores.length, (i) {
      final score = scores[i];
      String status;
      Color color;

      if (score >= 8) {
        status = 'Highly Stable';
        color = kScoreGreen;
      } else if (score >= 6) {
        status = 'Moderately Stable';
        color = kScoreAmber;
      } else if (score >= 4) {
        status = 'Unstable';
        color = kScoreAmber;
      } else {
        status = 'Critical Risk';
        color = kScoreRed;
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(pillars[i],
                style: const TextStyle(fontSize: 14, color: kTextPrimary)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: color),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM SERVICE
// ─────────────────────────────────────────────────────────────────────────────
class PremiumService {
  static const _key = 'is_premium';

  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> unlockPremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
