import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:fl_chart/fl_chart.dart';

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
                'See how well this relationship\nis meeting your needs',
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
          MaterialPageRoute(
            builder: (_) => AssessmentPage(lens: lens),
          ),
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
  final List<double> scores = List.filled(7, 5.0);

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
                min: 1,
                max: 10,
                divisions: 9,
                label: scores[i].round().toString(),
                onChanged: (v) => setState(() => scores[i] = v),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('See Results'),
        onPressed: () async {
          final average = (scores.reduce((a, b) => a + b) / scores.length) * 10;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setDouble('last_score', average);

          if (!context.mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ResultsPage(average: average),
            ),
          );
        },
      ),
    );
  }
}

/// ─────────────────────────────────────────
/// RESULTS
/// ─────────────────────────────────────────
class ResultsPage extends StatelessWidget {
  final double average;
  const ResultsPage({super.key, required this.average});

  String insight(double score) {
    if (score >= 80) return 'Strong alignment. This relationship is healthy.';
    if (score >= 60) return 'Moderate alignment. Some areas need attention.';
    return 'Low alignment. Serious gaps exist.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Alignment')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '${average.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(insight(average), textAlign: TextAlign.center),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                SharePlus.instance.share(
                  ShareParams(
                    text:
                        'I scored ${average.toStringAsFixed(0)}% on Align. Try it: https://align-app-9fd48.web.app/',
                  ),
                );
              },
              child: const Text('Share Result'),
            ),
            const SizedBox(height: 20),
            if (kIsWeb)
              const Text(
                'Premium is available on the mobile app.',
                style: TextStyle(fontStyle: FontStyle.italic),
              )
            else
              const UnlockButton(),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────
/// PAYWALL (MOBILE ONLY)
/// ─────────────────────────────────────────
class UnlockButton extends StatelessWidget {
  const UnlockButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text('Unlock Premium'),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaywallPage()),
        );
      },
    );
  }
}

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    const apiKey = kReleaseMode
        ? 'goog_PpWkcNjCqsaqoAuNHFCzlBuYfkK'
        : 'test_mIZCjyeqBNBaAtTTrqnBzcwuSeT';

    await Purchases.configure(PurchasesConfiguration(apiKey));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Premium purchase handled via Play Store')),
    );
  }
}
