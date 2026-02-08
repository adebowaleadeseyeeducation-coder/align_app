import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlignApp());
}

/// ─────────────────────────────────────────
/// APP ROOT
/// ─────────────────────────────────────────
class AlignApp extends StatelessWidget {
  const AlignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Align',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8F9B8B)),
        useMaterial3: true,
      ),
      home: const OnboardingPage(),
    );
  }
}

/// ─────────────────────────────────────────
/// ONBOARDING
/// ─────────────────────────────────────────
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Align',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Measure how well this relationship\nis truly aligned',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LensSelectionPage(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  child:
                      Text('Start Assessment', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────
/// LENS SELECTION
/// ─────────────────────────────────────────
enum Lens { universal, feminine, masculine }

class LensSelectionPage extends StatelessWidget {
  const LensSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Choose your lens', style: TextStyle(fontSize: 28)),
            const SizedBox(height: 40),
            _lensButton(context, 'Universal', Lens.universal),
            const SizedBox(height: 16),
            _lensButton(context, 'Feminine', Lens.feminine),
            const SizedBox(height: 16),
            _lensButton(context, 'Masculine', Lens.masculine),
          ],
        ),
      ),
    );
  }

  Widget _lensButton(BuildContext context, String text, Lens lens) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AssessmentPage(lens: lens)),
        );
      },
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: Center(child: Text(text, style: const TextStyle(fontSize: 18))),
      ),
    );
  }
}

/// ─────────────────────────────────────────
/// ASSESSMENT
/// ─────────────────────────────────────────
const List<String> pillars = [
  'Trust',
  'Respect',
  'Emotional Support',
  'Shared Values',
  'Communication',
  'Physical Intimacy',
  'Future Alignment',
];

class AssessmentPage extends StatefulWidget {
  final Lens lens;
  const AssessmentPage({super.key, required this.lens});

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  final List<double> scores = List.filled(7, 0);
  final Set<int> touched = {};

  bool get allCompleted => touched.length == pillars.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assessment')),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: pillars.length,
        itemBuilder: (context, i) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pillars[i], style: const TextStyle(fontSize: 18)),
              Slider(
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
              const SizedBox(height: 20),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: allCompleted
              ? () {
                  final total = scores.reduce((a, b) => a + b);
                  final percentage = (total / 70) * 100;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ResultsPage(percentage: percentage, scores: scores),
                    ),
                  );
                }
              : null,
          child: Text(
            allCompleted
                ? 'See Results'
                : 'Complete all ${pillars.length} pillars',
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────
/// INSIGHTS
/// ─────────────────────────────────────────
class InsightEngine {
  static String overall(double score) {
    if (score >= 85) return 'This relationship is strongly aligned.';
    if (score >= 70) return 'This relationship is healthy but vulnerable.';
    if (score >= 55) return 'Alignment is uneven and needs effort.';
    return 'This relationship faces serious long-term risks.';
  }

  static String pillar(String name, double value) {
    if (value >= 8) return '$name is a strong pillar.';
    if (value >= 6) return '$name is functional but inconsistent.';
    if (value >= 4) return '$name is unstable.';
    return '$name is critically weak.';
  }
}

/// ─────────────────────────────────────────
/// RESULTS
/// ─────────────────────────────────────────
class ResultsPage extends StatelessWidget {
  final double percentage;
  final List<double> scores;

  const ResultsPage({
    super.key,
    required this.percentage,
    required this.scores,
  });

  bool get isAndroid => !kIsWeb;

  @override
  Widget build(BuildContext context) {
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final minScore = scores.reduce((a, b) => a < b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Alignment')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(InsightEngine.overall(percentage)),
            const SizedBox(height: 24),
            Text(InsightEngine.pillar(
              pillars[scores.indexOf(maxScore)],
              maxScore,
            )),
            const SizedBox(height: 12),
            Text(InsightEngine.pillar(
              pillars[scores.indexOf(minScore)],
              minScore,
            )),
            const SizedBox(height: 32),

            /// ANDROID = FULL MODE
            if (isAndroid)
              ElevatedButton(
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text:
                          'I scored ${percentage.toStringAsFixed(0)}% on Align.',
                    ),
                  );
                },
                child: const Text('Share Result'),
              ),

            /// WEB = DEMO
            if (!isAndroid)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'This is a demo. Full experience available on mobile.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
