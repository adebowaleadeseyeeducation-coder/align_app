import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kReleaseMode;
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────
const kBrand = Color(0xFF00897B);
const kBrandDark = Color(0xFF00695C);
const kBrandLight = Color(0xFFD6F5F0);
const kBackground = Color(0xFFF0F7F6);
const kSurface = Color(0xFFFFFFFF);
const kBorder = Color(0xFFBEE3DC);
const kTextPrimary = Color(0xFF0A1F1D);
const kTextSub = Color(0xFF4A7A74);
const kScoreGreen = Color(0xFF00897B);
const kScoreAmber = Color(0xFFE09A2B);
const kScoreRed = Color(0xFFD94F3D);
const kPremiumGold = Color(0xFFC9A84C);

// Lens colours for the progress graph
const kLensUniversal = Color(0xFF00897B); // same as kBrand — teal
const kLensFeminine = Color(0xFF9B59A0); // muted purple — cool, cohesive
const kLensMasculine =
    Color(0xFF2E7D9F); // deep teal-blue — same family as kBrand

// ─────────────────────────────────────────────────────────────────────────────
// SUPABASE CONFIG
// ─────────────────────────────────────────────────────────────────────────────
const kSupabaseUrl = 'https://cebfleqyaqolpfeismlf.supabase.co';
const kSupabaseAnonKey = 'sb_publishable_i5UtYQMvrtKb19IUyq-vlg_KuAf0KF7';

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
void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  PremiumService.init().catchError((_) {});
  runApp(const AlignApp());
}

// Supabase client — safe getter
SupabaseClient get supabase => Supabase.instance.client;

class AlignApp extends StatefulWidget {
  const AlignApp({super.key});

  @override
  State<AlignApp> createState() => _AlignAppState();
}

class _AlignAppState extends State<AlignApp> {
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
// AUTH SERVICE
// ─────────────────────────────────────────────────────────────────────────────
class AuthService {
  static User? get currentUser {
    try {
      return supabase.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  static bool get isSignedIn => currentUser != null;

  static Future<AuthResponse?> signUp(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (_) {
      return null;
    }
  }

  static Future<AuthResponse?> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (_) {
      return null;
    }
  }

  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ASSESSMENT SERVICE — Supabase
// ─────────────────────────────────────────────────────────────────────────────
class AssessmentService {
  static Future<bool> save({
    required String lens,
    required List<double> scores,
    required double overallScore,
    required String grade,
  }) async {
    if (!AuthService.isSignedIn) return false;
    try {
      Supabase.instance.client;
      await supabase.from('assessments').insert({
        'user_id': AuthService.currentUser!.id,
        'lens': lens,
        'scores': scores,
        'overall_score': overallScore,
        'grade': grade,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    if (!AuthService.isSignedIn) return [];
    try {
      final data = await supabase
          .from('assessments')
          .select()
          .eq('user_id', AuthService.currentUser!.id)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  static Future<bool> delete(String id) async {
    try {
      await supabase.from('assessments').delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteMany(List<String> ids) async {
    if (ids.isEmpty) return true;
    try {
      await supabase.from('assessments').delete().inFilter('id', ids);
      return true;
    } catch (_) {
      return false;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ONBOARDING
// ─────────────────────────────────────────────────────────────────────────────
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  bool _supabaseReady = false;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSupabase();
    });
  }

  Future<void> _initSupabase() async {
    try {
      await Supabase.initialize(
        url: kSupabaseUrl,
        anonKey: kSupabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      if (mounted) {
        setState(() => _supabaseReady = true);
        supabase.auth.onAuthStateChange.listen((data) {
          if (mounted) setState(() {});
          // Handle password recovery event — route to reset screen
          if (data.event == AuthChangeEvent.passwordRecovery) {
            if (!mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
            );
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _supabaseReady = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Center(
                        child: Image.asset(
                          'assets/images/Align-Logo.png',
                          height: 220,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'In 2 minutes, know exactly where your relationship stands — scored, graded, and broken down pillar by pillar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 17, color: kTextSub, height: 1.5),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Most people are surprised by at least one result.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            color: kBrand,
                            fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      const AlignCard(
                        color: kBrandLight,
                        padding: EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 18, color: kTextSub),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Align is a self-reflection tool. It is not a substitute '
                                'for professional relationship counselling or therapy. '
                                'If you are experiencing serious difficulties, please '
                                'seek guidance from a qualified professional.',
                                style: TextStyle(
                                    fontSize: 12.5,
                                    color: kTextSub,
                                    height: 1.55),
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
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_supabaseReady && AuthService.isSignedIn) ...[
                            TextButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const AssessmentHistoryPage()),
                              ),
                              icon: const Icon(Icons.history_rounded,
                                  size: 16, color: kBrand),
                              label: const Text('My History',
                                  style:
                                      TextStyle(fontSize: 13, color: kBrand)),
                            ),
                            const Text('·',
                                style:
                                    TextStyle(fontSize: 12, color: kTextSub)),
                            TextButton(
                              onPressed: () async {
                                await AuthService.signOut();
                                setState(() {});
                              },
                              child: const Text('Sign Out',
                                  style:
                                      TextStyle(fontSize: 13, color: kTextSub)),
                            ),
                          ] else if (_supabaseReady) ...[
                            TextButton(
                              onPressed: () async {
                                final result = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const AuthPage()),
                                );
                                if (result == true) setState(() {});
                              },
                              child: const Text(
                                'Sign in to save your history',
                                style: TextStyle(fontSize: 13, color: kBrand),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const PrivacyPolicyPage()),
                            ),
                            child: const Text(
                              'Privacy Policy',
                              style: TextStyle(fontSize: 12, color: kTextSub),
                            ),
                          ),
                          const Text('·',
                              style: TextStyle(fontSize: 12, color: kTextSub)),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const TermsOfServicePage()),
                            ),
                            child: const Text(
                              'Terms of Service',
                              style: TextStyle(fontSize: 12, color: kTextSub),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AUTH PAGE — Sign In / Sign Up
// ─────────────────────────────────────────────────────────────────────────────
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isSignIn = true;
  bool _loading = false;
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showForgotPassword(BuildContext context) async {
    final resetEmailController = TextEditingController();
    final otpController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    // Steps: 0 = enter email, 1 = enter OTP, 2 = enter new password
    int step = 0;
    String? feedbackMessage;
    bool isError = false;
    bool loading = false;
    bool obscurePassword = true;
    bool obscureConfirm = true;
    String submittedEmail = '';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          // ── STEP 0 — Enter Email ──────────────────────────────────────────
          if (step == 0) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Reset Password',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter your email address. We will send you a 6-digit code to reset your password.',
                    style:
                        TextStyle(fontSize: 13, color: kTextSub, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: kTextSub),
                      filled: true,
                      fillColor: kSurface,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: kBorder)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: kBorder)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: kBrand, width: 2)),
                    ),
                  ),
                  if (feedbackMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isError
                            ? kScoreRed.withValues(alpha: 0.08)
                            : kBrandLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isError
                              ? kScoreRed.withValues(alpha: 0.3)
                              : kBrand.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(feedbackMessage!,
                          style: TextStyle(
                              fontSize: 12,
                              color: isError ? kScoreRed : kBrandDark,
                              height: 1.4)),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: loading ? null : () => Navigator.pop(ctx),
                  child:
                      const Text('Cancel', style: TextStyle(color: kTextSub)),
                ),
                TextButton(
                  onPressed: loading
                      ? null
                      : () async {
                          final email = resetEmailController.text.trim();
                          if (email.isEmpty) {
                            setDialogState(() {
                              feedbackMessage =
                                  'Please enter your email address.';
                              isError = true;
                            });
                            return;
                          }
                          setDialogState(() {
                            loading = true;
                            feedbackMessage = null;
                          });
                          try {
                            await supabase.auth.resetPasswordForEmail(
                              email,
                            );
                            submittedEmail = email;
                            setDialogState(() {
                              step = 1;
                              loading = false;
                              feedbackMessage = null;
                              isError = false;
                            });
                          } catch (e) {
                            setDialogState(() {
                              feedbackMessage =
                                  'Could not send code. Please check the email and try again.';
                              isError = true;
                              loading = false;
                            });
                          }
                        },
                  child: loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: kBrand))
                      : const Text('Send Code',
                          style: TextStyle(
                              color: kBrand, fontWeight: FontWeight.w700)),
                ),
              ],
            );
          }

          // ── STEP 1 — Enter OTP ───────────────────────────────────────────
          if (step == 1) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Enter Code',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A 6-digit code was sent to $submittedEmail. Enter it below.',
                    style:
                        TextStyle(fontSize: 13, color: kTextSub, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: '6-digit code',
                      labelStyle: const TextStyle(color: kTextSub),
                      filled: true,
                      fillColor: kSurface,
                      counterText: '',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: kBorder)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: kBorder)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: kBrand, width: 2)),
                    ),
                  ),
                  if (feedbackMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isError
                            ? kScoreRed.withValues(alpha: 0.08)
                            : kBrandLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isError
                              ? kScoreRed.withValues(alpha: 0.3)
                              : kBrand.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(feedbackMessage!,
                          style: TextStyle(
                              fontSize: 12,
                              color: isError ? kScoreRed : kBrandDark,
                              height: 1.4)),
                    ),
                  ],
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: loading
                        ? null
                        : () async {
                            setDialogState(() => loading = true);
                            try {
                              await supabase.auth.resetPasswordForEmail(
                                submittedEmail,
                              );
                              setDialogState(() {
                                feedbackMessage = 'New code sent.';
                                isError = false;
                                loading = false;
                              });
                            } catch (_) {
                              setDialogState(() {
                                feedbackMessage =
                                    'Could not resend. Try again.';
                                isError = true;
                                loading = false;
                              });
                            }
                          },
                    child: const Text(
                      'Resend code',
                      style: TextStyle(
                          fontSize: 12,
                          color: kBrand,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: loading
                      ? null
                      : () => setDialogState(() {
                            step = 0;
                            feedbackMessage = null;
                            otpController.clear();
                          }),
                  child: const Text('Back', style: TextStyle(color: kTextSub)),
                ),
                TextButton(
                  onPressed: loading
                      ? null
                      : () async {
                          final otp = otpController.text.trim();
                          if (otp.length != 6) {
                            setDialogState(() {
                              feedbackMessage =
                                  'Please enter the full 6-digit code.';
                              isError = true;
                            });
                            return;
                          }
                          setDialogState(() {
                            loading = true;
                            feedbackMessage = null;
                          });
                          try {
                            await supabase.auth.verifyOTP(
                              email: submittedEmail,
                              token: otp,
                              type: OtpType.recovery,
                            );
                            setDialogState(() {
                              step = 2;
                              loading = false;
                              feedbackMessage = null;
                              isError = false;
                            });
                          } catch (e) {
                            setDialogState(() {
                              feedbackMessage =
                                  'Invalid or expired code. Please try again or resend.';
                              isError = true;
                              loading = false;
                            });
                          }
                        },
                  child: loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: kBrand))
                      : const Text('Verify',
                          style: TextStyle(
                              color: kBrand, fontWeight: FontWeight.w700)),
                ),
              ],
            );
          }

          // ── STEP 2 — Enter New Password ──────────────────────────────────
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Set New Password',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your new password. Must be at least 8 characters.',
                  style: TextStyle(fontSize: 13, color: kTextSub, height: 1.5),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: const TextStyle(color: kTextSub),
                    filled: true,
                    fillColor: kSurface,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kBorder)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kBorder)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kBrand, width: 2)),
                    suffixIcon: IconButton(
                      icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: kTextSub),
                      onPressed: () => setDialogState(
                          () => obscurePassword = !obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: const TextStyle(color: kTextSub),
                    filled: true,
                    fillColor: kSurface,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kBorder)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kBorder)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kBrand, width: 2)),
                    suffixIcon: IconButton(
                      icon: Icon(
                          obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: kTextSub),
                      onPressed: () => setDialogState(
                          () => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                ),
                if (feedbackMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isError
                          ? kScoreRed.withValues(alpha: 0.08)
                          : kBrandLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isError
                            ? kScoreRed.withValues(alpha: 0.3)
                            : kBrand.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(feedbackMessage!,
                        style: TextStyle(
                            fontSize: 12,
                            color: isError ? kScoreRed : kBrandDark,
                            height: 1.4)),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: loading ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: kTextSub)),
              ),
              TextButton(
                onPressed: loading
                    ? null
                    : () async {
                        final password = newPasswordController.text.trim();
                        final confirm = confirmPasswordController.text.trim();
                        if (password.length < 8) {
                          setDialogState(() {
                            feedbackMessage =
                                'Password must be at least 8 characters.';
                            isError = true;
                          });
                          return;
                        }
                        if (password != confirm) {
                          setDialogState(() {
                            feedbackMessage = 'Passwords do not match.';
                            isError = true;
                          });
                          return;
                        }
                        setDialogState(() {
                          loading = true;
                          feedbackMessage = null;
                        });
                        try {
                          await supabase.auth
                              .updateUser(UserAttributes(password: password));
                          await supabase.auth.signOut();
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Password updated successfully. Please sign in with your new password.'),
                              backgroundColor: kBrand,
                              duration: Duration(seconds: 4),
                            ),
                          );
                        } catch (e) {
                          setDialogState(() {
                            feedbackMessage =
                                'Could not update password. Please try again.';
                            isError = true;
                            loading = false;
                          });
                        }
                      },
                child: loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: kBrand))
                    : const Text('Update Password',
                        style: TextStyle(
                            color: kBrand, fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );

    resetEmailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email and password.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignIn) {
        final response = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (response.user != null && mounted) {
          Navigator.pop(context, true);
        } else {
          setState(() =>
              _errorMessage = 'Sign in failed. Please check your details.');
        }
      } else {
        if (password.length < 8) {
          setState(() {
            _loading = false;
            _errorMessage = 'Password must be at least 8 characters long.';
          });
          return;
        }
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
        );
        if (response.user != null && mounted) {
          if (response.session == null) {
            setState(() {
              _loading = false;
              _errorMessage = null;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Account created! Please check your email to confirm your account, then sign in.'),
                  backgroundColor: kBrand,
                  duration: Duration(seconds: 5),
                ),
              );
              setState(() => _isSignIn = true);
            }
            return;
          }
          Navigator.pop(context, true);
        } else {
          setState(() => _errorMessage =
              'Sign up failed. This email may already be registered.');
        }
      }
    } catch (e) {
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('invalid login credentials') ||
          errorString.contains('invalid_credentials')) {
        setState(() =>
            _errorMessage = 'Incorrect email or password. Please try again.');
      } else if (errorString.contains('email not confirmed')) {
        setState(() => _errorMessage =
            'Please confirm your email address before signing in. Check your inbox.');
      } else if (errorString.contains('user not found')) {
        setState(() => _errorMessage =
            'No account found with this email. Please sign up first.');
      } else if (errorString.contains('too many requests')) {
        setState(() => _errorMessage =
            'Too many attempts. Please wait a few minutes and try again.');
      } else {
        setState(
            () => _errorMessage = 'Something went wrong. Please try again.');
      }
    }

    setState(() => _loading = false);
  }

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
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isSignIn ? 'Welcome back' : 'Create account',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isSignIn
                    ? 'Sign in to access your assessment history.'
                    : 'Save your assessments and track progress over time.',
                style:
                    const TextStyle(fontSize: 14, color: kTextSub, height: 1.5),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: kTextSub),
                  filled: true,
                  fillColor: kSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBrand, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: kTextSub),
                  filled: true,
                  fillColor: kSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBrand, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: kTextSub,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              if (_isSignIn)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showForgotPassword(context),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(fontSize: 13, color: kBrand),
                    ),
                  ),
                ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kScoreRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kScoreRed.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: kScoreRed, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style:
                              const TextStyle(fontSize: 13, color: kScoreRed),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: AlignButton(
                  label: _loading
                      ? 'Please wait...'
                      : (_isSignIn ? 'Sign In' : 'Create Account'),
                  onPressed: _loading ? null : _submit,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => setState(() {
                    _isSignIn = !_isSignIn;
                    _errorMessage = null;
                  }),
                  child: Text(
                    _isSignIn
                        ? "Don't have an account? Sign up"
                        : 'Already have an account? Sign in',
                    style: const TextStyle(fontSize: 13, color: kBrand),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ASSESSMENT HISTORY PAGE
// ─────────────────────────────────────────────────────────────────────────────
class AssessmentHistoryPage extends StatefulWidget {
  const AssessmentHistoryPage({super.key});

  @override
  State<AssessmentHistoryPage> createState() => _AssessmentHistoryPageState();
}

class _AssessmentHistoryPageState extends State<AssessmentHistoryPage> {
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;
  bool _isPremium = false;

  // Selection mode state
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _checkPremium();
  }

  Future<void> _checkPremium() async {
    if (kDebugMode) {
      setState(() => _isPremium = true);
      return;
    }
    final premium = await PremiumService.isPremium()
        .timeout(const Duration(seconds: 5), onTimeout: () => false);
    setState(() => _isPremium = premium);
  }

  Future<void> _loadHistory() async {
    final data = await AssessmentService.getHistory();
    setState(() {
      _history = data;
      _loading = false;
    });
  }

  Future<void> _delete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Assessment',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: kTextPrimary)),
        content: const Text(
            'Are you sure you want to delete this assessment? This cannot be undone.',
            style: TextStyle(fontSize: 14, color: kTextSub)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: kTextSub)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: kScoreRed)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await AssessmentService.delete(id);
      _loadHistory();
    }
  }

  void _enterSelectionMode(String id) {
    setState(() {
      _selectionMode = true;
      _selectedIds.add(id);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _openPaywall() async {
    final purchased = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PaywallPage()),
    );
    if (purchased == true && mounted) setState(() => _isPremium = true);
  }

  void _enterSelectModeEmpty() {
    setState(() => _selectionMode = true);
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIds.length == _history.length) {
        _selectedIds.clear();
      } else {
        _selectedIds
          ..clear()
          ..addAll(_history.map((e) => e['id'] as String));
      }
    });
  }

  Future<void> _deleteSelected() async {
    final count = _selectedIds.length;
    if (count == 0) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete $count assessment${count == 1 ? '' : 's'}?',
          style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w700, color: kTextPrimary),
        ),
        content: const Text(
          'This cannot be undone.',
          style: TextStyle(fontSize: 14, color: kTextSub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: kTextSub)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: kScoreRed)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await AssessmentService.deleteMany(_selectedIds.toList());
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete. Please try again.'),
          backgroundColor: kScoreRed,
        ),
      );
      return;
    }
    _exitSelectionMode();
    await _loadHistory();
  }

  void _plotSelected() {
    if (!_isPremium) {
      _openPaywall();
      return;
    }
    final selected = _history
        .where((item) => _selectedIds.contains(item['id'] as String))
        .toList();
    _exitSelectionMode();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProgressGraphPage(
          history: _history,
          customSelection: selected,
          initialTab: GraphTab.custom,
        ),
      ),
    );
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A':
      case 'B':
        return kScoreGreen;
      case 'C':
      case 'D':
        return kScoreAmber;
      default:
        return kScoreRed;
    }
  }

  String _formatDate(String isoDate) {
    final dt = DateTime.parse(isoDate).toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _lensLabel(String lens) {
    switch (lens) {
      case 'feminine':
        return 'Feminine Lens';
      case 'masculine':
        return 'Masculine Lens';
      default:
        return 'Universal Lens';
    }
  }

  Color _lensColor(String lens) {
    switch (lens) {
      case 'feminine':
        return kLensFeminine;
      case 'masculine':
        return kLensMasculine;
      default:
        return kLensUniversal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_selectionMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _selectionMode) {
          _exitSelectionMode();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset('assets/images/Align-Logo.png',
                  height: 30, fit: BoxFit.contain),
              const SizedBox(width: 8),
              const Text('Align',
                  style: TextStyle(
                      color: kBrand,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          actions: [
            // View Progress button — only shown for premium users with 2+ assessments
            if (_isPremium && _history.length >= 2 && !_selectionMode)
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProgressGraphPage(
                      history: _history,
                      customSelection: const [],
                      initialTab: GraphTab.day,
                    ),
                  ),
                ),
                icon: const Icon(Icons.show_chart_rounded,
                    size: 16, color: kBrand),
                label: const Text('Progress',
                    style: TextStyle(fontSize: 13, color: kBrand)),
              ),
            if (!_selectionMode && _history.isNotEmpty)
              TextButton(
                onPressed: _enterSelectModeEmpty,
                child: const Text('Select',
                    style: TextStyle(fontSize: 13, color: kBrand)),
              ),
            if (_selectionMode)
              TextButton(
                onPressed: _exitSelectionMode,
                child: const Text('Cancel',
                    style: TextStyle(fontSize: 13, color: kTextSub)),
              ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: kBrand))
            : _history.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_rounded,
                              size: 56, color: kBrand.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          const Text(
                            'No assessments yet',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: kTextPrimary),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Complete an assessment and your results will be saved here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14, color: kTextSub, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  )
                : Stack(
                    children: [
                      RefreshIndicator(
                        color: kBrand,
                        onRefresh: _loadHistory,
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            16,
                            20,
                            _selectionMode ? 170 : 32,
                          ),
                          itemCount: _history.length,
                          itemBuilder: (context, i) {
                            final item = _history[i];
                            final grade = item['grade'] as String;
                            final score =
                                (item['overall_score'] as num).toDouble();
                            final lens = item['lens'] as String;
                            final date = item['created_at'] as String;
                            final id = item['id'] as String;
                            final gradeCol = _gradeColor(grade);
                            final isSelected = _selectedIds.contains(id);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: GestureDetector(
                                onLongPress: () {
                                  if (!_selectionMode) {
                                    _enterSelectionMode(id);
                                  }
                                },
                                onTap: () {
                                  if (_selectionMode) {
                                    _toggleSelection(id);
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? kBrand.withValues(alpha: 0.07)
                                        : kSurface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? kBrand : kBorder,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  child: Row(
                                    children: [
                                      // Selection checkbox overlay
                                      if (_selectionMode) ...[
                                        AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 150),
                                          width: 24,
                                          height: 24,
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected
                                                ? kBrand
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: isSelected
                                                  ? kBrand
                                                  : kTextSub,
                                              width: 2,
                                            ),
                                          ),
                                          child: isSelected
                                              ? const Icon(Icons.check,
                                                  size: 14, color: kSurface)
                                              : null,
                                        ),
                                      ],
                                      // Grade badge
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: gradeCol,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: gradeCol.withValues(
                                                  alpha: 0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            grade,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: kSurface,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${score.toStringAsFixed(0)}%',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: kTextPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: _lensColor(lens),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  _lensLabel(lens),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: _lensColor(lens),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  _formatDate(date),
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      color: kTextSub),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!_selectionMode)
                                        IconButton(
                                          onPressed: () => _delete(id),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: kTextSub,
                                              size: 18),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // ── SELECTION MODE BOTTOM BAR ──────────────────────────
                      if (_selectionMode)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                            decoration: BoxDecoration(
                              color: kSurface,
                              border:
                                  const Border(top: BorderSide(color: kBorder)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${_selectedIds.length} selected',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: kTextPrimary,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _toggleSelectAll,
                                      child: Text(
                                        _selectedIds.length == _history.length
                                            ? 'Clear'
                                            : 'Select all',
                                        style: const TextStyle(
                                            fontSize: 13, color: kBrand),
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: _selectedIds.isEmpty
                                          ? null
                                          : _deleteSelected,
                                      icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          size: 18),
                                      label: const Text('Delete'),
                                      style: TextButton.styleFrom(
                                          foregroundColor: kScoreRed),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: double.infinity,
                                  child: AlignButton(
                                    label: 'Plot Selected',
                                    icon: _isPremium
                                        ? Icons.show_chart_rounded
                                        : Icons.lock_outline_rounded,
                                    onPressed: _selectedIds.length >= 2
                                        ? _plotSelected
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROGRESS GRAPH PAGE
// ─────────────────────────────────────────────────────────────────────────────

enum GraphTab { day, week, month, year, custom }

class ProgressGraphPage extends StatefulWidget {
  final List<Map<String, dynamic>> history;
  final List<Map<String, dynamic>> customSelection;
  final GraphTab initialTab;

  const ProgressGraphPage({
    super.key,
    required this.history,
    required this.customSelection,
    required this.initialTab,
  });

  @override
  State<ProgressGraphPage> createState() => _ProgressGraphPageState();
}

class _ProgressGraphPageState extends State<ProgressGraphPage> {
  late GraphTab _activeTab;

  static const _monthLabels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
  }

  // ── DATA HELPERS ─────────────────────────────────────────────────────────

  bool _tabEnabled(GraphTab tab) {
    if (tab == GraphTab.custom) return widget.customSelection.length >= 2;
    final buckets = _buildBuckets(tab);
    for (final lensData in buckets.values) {
      if (lensData.length >= 2) return true;
    }
    return false;
  }

  Map<String, List<_BucketPoint>> _buildBuckets(GraphTab tab) {
    final Map<String, Map<String, List<double>>> grouped = {
      'universal': {},
      'feminine': {},
      'masculine': {},
    };
    final source = widget.history.reversed.toList();
    for (final item in source) {
      final lens = item['lens'] as String;
      if (!grouped.containsKey(lens)) continue;
      final score = (item['overall_score'] as num).toDouble();
      final dt = DateTime.parse(item['created_at'] as String).toLocal();
      final key = _bucketKey(dt, tab);
      grouped[lens]!.putIfAbsent(key, () => []).add(score);
    }
    final Map<String, List<_BucketPoint>> result = {};
    for (final lens in grouped.keys) {
      final bucketMap = grouped[lens]!;
      final points = bucketMap.entries.map((e) {
        final avg = e.value.reduce((a, b) => a + b) / e.value.length;
        return _BucketPoint(key: e.key, avg: avg, count: e.value.length);
      }).toList();
      points.sort((a, b) => a.key.compareTo(b.key));
      result[lens] = points;
    }
    return result;
  }

  String _bucketKey(DateTime dt, GraphTab tab) {
    switch (tab) {
      case GraphTab.day:
        return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      case GraphTab.week:
        final startOfYear = DateTime(dt.year, 1, 1);
        final weekNum = ((dt.difference(startOfYear).inDays) / 7).ceil();
        return '${dt.year}-W${weekNum.toString().padLeft(2, '0')}';
      case GraphTab.month:
        return '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
      case GraphTab.year:
        return '${dt.year}';
      case GraphTab.custom:
        return '';
    }
  }

  String _bucketLabel(String key, GraphTab tab, {bool short = false}) {
    try {
      switch (tab) {
        case GraphTab.day:
          final dt = DateTime.parse(key);
          return short
              ? '${dt.day} ${_monthLabels[dt.month - 1]}'
              : '${dt.day} ${_monthLabels[dt.month - 1]} ${dt.year}';
        case GraphTab.week:
          final parts = key.split('-W');
          return short ? 'Wk ${parts[1]}' : 'Week ${parts[1]}, ${parts[0]}';
        case GraphTab.month:
          final parts = key.split('-');
          final mon = _monthLabels[int.parse(parts[1]) - 1];
          return short ? mon : '$mon ${parts[0]}';
        case GraphTab.year:
          return key;
        case GraphTab.custom:
          return '';
      }
    } catch (_) {
      return key;
    }
  }

  String _gradeFromScore(double score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  String _buildSummary() {
    if (_activeTab == GraphTab.custom) {
      final count = widget.customSelection.length;
      final scores = widget.customSelection
          .map((e) => (e['overall_score'] as num).toDouble())
          .toList();
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      final highest = scores.reduce((a, b) => a > b ? a : b);
      final lowest = scores.reduce((a, b) => a < b ? a : b);
      return 'Showing $count selected assessments. '
          'Average score: ${avg.toStringAsFixed(0)}%, '
          'ranging from ${lowest.toStringAsFixed(0)}% to ${highest.toStringAsFixed(0)}%.';
    }

    final buckets = _buildBuckets(_activeTab);
    final lensNames = {
      'universal': 'Universal',
      'feminine': 'Feminine',
      'masculine': 'Masculine',
    };

    String? mostConsistentLens;
    double smallestRange = double.infinity;
    String? mostVariableLens;
    double largestRange = 0;

    for (final lens in buckets.keys) {
      final pts = buckets[lens]!;
      if (pts.length < 2) continue;
      final scores = pts.map((p) => p.avg).toList();
      final range = scores.reduce((a, b) => a > b ? a : b) -
          scores.reduce((a, b) => a < b ? a : b);
      if (range < smallestRange) {
        smallestRange = range;
        mostConsistentLens = lens;
      }
      if (range > largestRange) {
        largestRange = range;
        mostVariableLens = lens;
      }
    }

    final trend = _trend();
    final trendText = trend > 3
        ? 'Your scores are trending upward — good momentum.'
        : trend < -3
            ? 'Your scores have dipped recently — worth reflecting on.'
            : 'Your scores are holding steady.';

    if (mostConsistentLens != null &&
        mostVariableLens != null &&
        mostConsistentLens != mostVariableLens) {
      return '${lensNames[mostConsistentLens]} has been your most consistent lens. '
          '${lensNames[mostVariableLens]} shows the most variation. $trendText';
    }
    if (mostConsistentLens != null) {
      return '${lensNames[mostConsistentLens]} has been your most consistent lens. $trendText';
    }
    return trendText;
  }

  Map<String, List<_RawPoint>> _buildCustomRawPoints() {
    final Map<String, List<_RawPoint>> raw = {
      'universal': [],
      'feminine': [],
      'masculine': [],
    };
    final sorted = List<Map<String, dynamic>>.from(widget.customSelection)
      ..sort((a, b) =>
          (a['created_at'] as String).compareTo(b['created_at'] as String));
    for (final item in sorted) {
      final lens = item['lens'] as String;
      if (!raw.containsKey(lens)) continue;
      raw[lens]!.add(_RawPoint(
        score: (item['overall_score'] as num).toDouble(),
        date: DateTime.parse(item['created_at'] as String).toLocal(),
        lens: lens,
      ));
    }
    return raw;
  }

  // ── STATS ─────────────────────────────────────────────────────────────────

  double _bestWeekAverage() {
    final weekBuckets = _buildBuckets(GraphTab.week);
    double best = 0;
    for (final pts in weekBuckets.values) {
      for (final p in pts) {
        if (p.avg > best) best = p.avg;
      }
    }
    return best;
  }

  double _trend() {
    final buckets = _buildBuckets(
        _activeTab == GraphTab.custom ? GraphTab.day : _activeTab);
    final Map<String, List<double>> merged = {};
    for (final pts in buckets.values) {
      for (final p in pts) {
        merged.putIfAbsent(p.key, () => []).add(p.avg);
      }
    }
    final keys = merged.keys.toList()..sort();
    if (keys.length < 2) return 0;
    final latest =
        merged[keys.last]!.reduce((a, b) => a + b) / merged[keys.last]!.length;
    final previous = merged[keys[keys.length - 2]]!.reduce((a, b) => a + b) /
        merged[keys[keys.length - 2]]!.length;
    return latest - previous;
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────

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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const Text(
              'Progress Over Time',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.history.length} assessment${widget.history.length == 1 ? '' : 's'} recorded',
              style: const TextStyle(fontSize: 13, color: kTextSub),
            ),
            const SizedBox(height: 16),
            _buildTabBar(),
            const SizedBox(height: 16),
            // ── PLAIN ENGLISH SUMMARY ──────────────────────────────────────
            AlignCard(
              color: kBrandLight,
              padding: const EdgeInsets.all(14),
              child: Text(
                _buildSummary(),
                style: const TextStyle(
                    fontSize: 13, color: kBrandDark, height: 1.5),
              ),
            ),
            const SizedBox(height: 12),
            // ── GRAPH CARD ─────────────────────────────────────────────────
            AlignCard(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGraph(),
                  const SizedBox(height: 12),
                  _buildLegend(),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _activeTab == GraphTab.custom
                          ? 'Each dot is one selected assessment. Tap a dot for details.'
                          : _activeTab == GraphTab.day
                              ? 'Each dot is the average score for that day. Tap for details.'
                              : _activeTab == GraphTab.week
                                  ? 'Each dot is the average score for that week. Tap for details.'
                                  : _activeTab == GraphTab.month
                                      ? 'Each dot is the average score for that month. Tap for details.'
                                      : 'Each dot is the average score for that year. Tap for details.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 11, color: kTextSub, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _buildStatsCards(),
            const SizedBox(height: 14),
            if (_activeTab != GraphTab.custom)
              AlignCard(
                color: kBrandLight,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: const [
                    Icon(Icons.touch_app_rounded, size: 16, color: kBrand),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Long-press any assessment in History to select specific entries and plot them on a Custom view.',
                        style: TextStyle(
                            fontSize: 12, color: kBrandDark, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    const tabs = [
      (GraphTab.day, 'Day'),
      (GraphTab.week, 'Week'),
      (GraphTab.month, 'Month'),
      (GraphTab.year, 'Year'),
      (GraphTab.custom, 'Custom'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: tabs.map((t) {
          final tab = t.$1;
          final label = t.$2;
          final enabled = _tabEnabled(tab);
          final active = _activeTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: enabled ? () => setState(() => _activeTab = tab) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? kBrand : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active
                        ? kSurface
                        : enabled
                            ? kTextPrimary
                            : kTextSub.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGraph() {
    if (_activeTab == GraphTab.custom) return _buildCustomGraph();
    return _buildBucketGraph();
  }

  Widget _buildBucketGraph() {
    final buckets = _buildBuckets(_activeTab);
    final allKeys = <String>{};
    for (final pts in buckets.values) {
      for (final p in pts) {
        allKeys.add(p.key);
      }
    }
    final sortedKeys = allKeys.toList()..sort();

    if (sortedKeys.length < 2) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Not enough data for this view yet.\nTry a different time range.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: kTextSub, height: 1.5),
          ),
        ),
      );
    }

    List<LineChartBarData> lineBars = [];
    final lensConfig = {
      'universal': (kLensUniversal, 'Universal'),
      'feminine': (kLensFeminine, 'Feminine'),
      'masculine': (kLensMasculine, 'Masculine'),
    };

    for (final entry in lensConfig.entries) {
      final lens = entry.key;
      final color = entry.value.$1;
      final pts = buckets[lens] ?? [];
      if (pts.length < 2) continue;
      final spots = pts.map((p) {
        final x = sortedKeys.indexOf(p.key).toDouble();
        return FlSpot(x, p.avg);
      }).toList();
      lineBars.add(LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: 2.5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
            radius: 5,
            color: color,
            strokeWidth: 2,
            strokeColor: kSurface,
          ),
        ),
        belowBarData: BarAreaData(show: false),
      ));
    }

    if (lineBars.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Not enough data for this view yet.\nTry a different time range.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: kTextSub, height: 1.5),
          ),
        ),
      );
    }

    // Cap x-axis to real data — no phantom positions beyond the last point
    final maxX = (sortedKeys.length - 1).toDouble();
    final skipLabels = sortedKeys.length > 8;

    return SizedBox(
      height: 240,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          minX: 0,
          maxX: maxX,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: kBorder, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 25,
                reservedSize: 36,
                getTitlesWidget: (value, _) => Text(
                  '${value.toInt()}%',
                  style: const TextStyle(fontSize: 10, color: kTextSub),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= sortedKeys.length) {
                    return const SizedBox.shrink();
                  }
                  if (skipLabels && idx % 2 != 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _bucketLabel(sortedKeys[idx], _activeTab, short: true),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 9, color: kTextSub),
                    ),
                  );
                },
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: lineBars,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((s) {
                  final idx = s.x.toInt();
                  if (idx < 0 || idx >= sortedKeys.length) {
                    return LineTooltipItem(
                        '', const TextStyle(color: kSurface));
                  }
                  final fullLabel =
                      _bucketLabel(sortedKeys[idx], _activeTab, short: false);
                  final grade = _gradeFromScore(s.y);
                  return LineTooltipItem(
                    '$fullLabel\n${s.y.toStringAsFixed(0)}%  ·  Grade $grade',
                    const TextStyle(
                      color: kSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomGraph() {
    final rawMap = _buildCustomRawPoints();
    final sorted = List<Map<String, dynamic>>.from(widget.customSelection)
      ..sort((a, b) =>
          (a['created_at'] as String).compareTo(b['created_at'] as String));

    List<LineChartBarData> lineBars = [];
    final lensConfig = {
      'universal': kLensUniversal,
      'feminine': kLensFeminine,
      'masculine': kLensMasculine,
    };

    for (final entry in lensConfig.entries) {
      final lens = entry.key;
      final color = entry.value;
      final pts = rawMap[lens] ?? [];
      if (pts.isEmpty) continue;
      final spots = pts.map((p) {
        final globalIdx = sorted.indexWhere((item) =>
            item['lens'] == lens &&
            (item['overall_score'] as num).toDouble() == p.score &&
            DateTime.parse(item['created_at'] as String)
                    .toLocal()
                    .difference(p.date)
                    .inSeconds
                    .abs() <
                2);
        return FlSpot(globalIdx >= 0 ? globalIdx.toDouble() : 0, p.score);
      }).toList();
      lineBars.add(LineChartBarData(
        spots: spots,
        isCurved: false,
        color: color,
        barWidth: 2.5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
            radius: 6,
            color: color,
            strokeWidth: 2.5,
            strokeColor: kSurface,
          ),
        ),
        belowBarData: BarAreaData(show: false),
      ));
    }

    final maxX = (sorted.length - 1).toDouble();
    final skipLabels = sorted.length > 8;

    return SizedBox(
      height: 240,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          minX: 0,
          maxX: maxX < 1 ? 1 : maxX,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: kBorder, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 25,
                reservedSize: 36,
                getTitlesWidget: (value, _) => Text(
                  '${value.toInt()}%',
                  style: const TextStyle(fontSize: 10, color: kTextSub),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= sorted.length) {
                    return const SizedBox.shrink();
                  }
                  if (skipLabels && idx % 2 != 0) {
                    return const SizedBox.shrink();
                  }
                  final dt = DateTime.parse(sorted[idx]['created_at'] as String)
                      .toLocal();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${dt.day} ${_monthLabels[dt.month - 1]}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 9, color: kTextSub),
                    ),
                  );
                },
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: lineBars,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((s) {
                  final idx = s.x.toInt();
                  if (idx < 0 || idx >= sorted.length) {
                    return LineTooltipItem(
                        '', const TextStyle(color: kSurface));
                  }
                  final item = sorted[idx];
                  final dt =
                      DateTime.parse(item['created_at'] as String).toLocal();
                  final dateStr =
                      '${dt.day} ${_monthLabels[dt.month - 1]} ${dt.year}';
                  final lens = item['lens'] as String;
                  final lensLabel = lens == 'feminine'
                      ? 'Feminine'
                      : lens == 'masculine'
                          ? 'Masculine'
                          : 'Universal';
                  final grade = _gradeFromScore(s.y);
                  return LineTooltipItem(
                    '$dateStr  ·  $lensLabel\n${s.y.toStringAsFixed(0)}%  ·  Grade $grade',
                    const TextStyle(
                      color: kSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(kLensUniversal, 'Universal'),
        const SizedBox(width: 16),
        _legendDot(kLensFeminine, 'Feminine'),
        const SizedBox(width: 16),
        _legendDot(kLensMasculine, 'Masculine'),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, color: kTextSub)),
      ],
    );
  }

  Widget _buildStatsCards() {
    final bestWeek = _bestWeekAverage();
    final trend = _trend();
    final trendUp = trend >= 0;
    final trendColor = trendUp ? kScoreGreen : kScoreRed;
    final trendIcon =
        trendUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    final trendLabel = '${trendUp ? '+' : ''}${trend.toStringAsFixed(0)}%';

    return Row(
      children: [
        Expanded(
          child: AlignCard(
            color: kBrandLight,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Best Week Avg',
                    style: TextStyle(fontSize: 11, color: kTextSub)),
                const SizedBox(height: 6),
                Text(
                  bestWeek > 0 ? '${bestWeek.toStringAsFixed(0)}%' : '—',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: kScoreGreen,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Highest avg across all weeks',
                  style: TextStyle(fontSize: 10, color: kTextSub),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AlignCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Trend',
                    style: TextStyle(fontSize: 11, color: kTextSub)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (trend != 0)
                      Icon(trendIcon, size: 18, color: trendColor),
                    if (trend != 0) const SizedBox(width: 4),
                    Text(
                      trend == 0 ? '—' : trendLabel,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: trend == 0 ? kTextSub : trendColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'vs previous period',
                  style: TextStyle(fontSize: 10, color: kTextSub),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GRAPH DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────
class _BucketPoint {
  final String key;
  final double avg;
  final int count;
  const _BucketPoint(
      {required this.key, required this.avg, required this.count});
}

class _RawPoint {
  final double score;
  final DateTime date;
  final String lens;
  const _RawPoint(
      {required this.score, required this.date, required this.lens});
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
                'Choose the perspective you want to reflect from.\nThis shapes how questions and insights are framed.',
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
        itemCount: pillars.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: AlignCard(
                color: kBrandLight,
                padding: EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline_rounded,
                        size: 18, color: kBrand),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Rate each pillar honestly — there are no right answers. Most people find at least one pillar surprises them.',
                        style: TextStyle(
                            fontSize: 13, color: kBrandDark, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final i = index - 1;
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
                onPressed: () async {
                  // Show warning dialog if any pillars are unrated
                  if (touched.length < pillars.length) {
                    final unrated = pillars.length - touched.length;
                    final proceed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: const Text(
                          'Some pillars are unrated',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: kTextPrimary,
                          ),
                        ),
                        content: Text(
                          '$unrated pillar${unrated == 1 ? '' : 's'} '
                          '${unrated == 1 ? 'has' : 'have'} not been rated and '
                          '${unrated == 1 ? 'will' : 'will all'} score as 0. '
                          'This will lower your overall result.\n\nDo you want to continue anyway?',
                          style: const TextStyle(
                              fontSize: 14, color: kTextSub, height: 1.5),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Go Back',
                                style: TextStyle(color: kTextSub)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Continue Anyway',
                              style: TextStyle(
                                  color: kBrand, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (proceed != true) return;
                  }

                  final total = scores.reduce((a, b) => a + b);
                  final percentage = (total / 70) * 100;
                  if (!context.mounted) return;
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

  static String evenly(double value) {
    if (value >= 8) {
      return 'You rated every pillar the same, and it is high. This relationship is strong across the board.';
    }
    if (value >= 6) {
      return 'You rated every pillar the same. No single pillar stands out, so look at which ones feel most important to you.';
    }
    return 'You rated every pillar the same, and it is low. Start with the pillar that matters most to you.';
  }

  static String strongest(String name, double value) {
    if (value >= 8) {
      return '$name is your anchor. It is carrying a lot of weight in this relationship.';
    }
    if (value >= 6) {
      return '$name is your best-scoring pillar, but it is not yet a firm anchor.';
    }
    return '$name scored highest, but even your strongest pillar is under strain.';
  }

  static String weakest(String name, double value) {
    if (value >= 8) {
      return '$name scored lowest, yet it is still strong. This relationship is well balanced.';
    }
    if (value >= 6) {
      return '$name is the pillar to nurture first. Small, consistent effort here will pay off.';
    }
    if (value >= 4) {
      return '$name is unstable. It is the area most likely to cause friction if left alone.';
    }
    return '$name is critically weak. It needs focused attention before anything else.';
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
// Short labels for the share card (full names clip on a 320px-wide card)
const List<String> kShortPillars = [
  'Trust',
  'Respect',
  'Support',
  'Values',
  'Comms',
  'Intimacy',
  'Future',
];

class PillarRadarChart extends StatelessWidget {
  final List<double> scores;
  final double? height; // null = fill parent (used by the share card)
  final bool compact; // true = share card styling
  final List<double>? compareScores; // partner shape (optional)

  const PillarRadarChart({
    super.key,
    required this.scores,
    this.height = 300,
    this.compact = false,
    this.compareScores,
  });

  // Invisible dataset that pins the chart scale (0-10) so the shape is honest
  RadarDataSet _pin(double v) => RadarDataSet(
        dataEntries: List.generate(pillars.length, (_) => RadarEntry(value: v)),
        borderColor: Colors.transparent,
        fillColor: Colors.transparent,
        borderWidth: 0,
        entryRadius: 0,
      );

  @override
  Widget build(BuildContext context) {
    final chart = RadarChart(
      RadarChartData(
        radarShape: RadarShape.circle,
        tickCount: 5,
        // No numeric tick labels anywhere on the free chart
        ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 1),
        radarBorderData: const BorderSide(color: kBorder),
        gridBorderData: const BorderSide(color: kBorder),
        tickBorderData: const BorderSide(color: kBorder, width: 1),
        titleTextStyle: TextStyle(
          fontSize: compact ? 10.5 : 12,
          color: kTextSub,
          fontWeight: FontWeight.w600,
        ),
        getTitle: (index, angle) => RadarChartTitle(text: kShortPillars[index]),
        dataSets: [
          _pin(0),
          _pin(10),
          if (compareScores != null)
            RadarDataSet(
              dataEntries:
                  compareScores!.map((e) => RadarEntry(value: e)).toList(),
              borderColor: kLensFeminine,
              fillColor: kLensFeminine.withValues(alpha: 0.12),
              borderWidth: 2.5,
              entryRadius: 3,
            ),
          RadarDataSet(
            dataEntries: scores.map((e) => RadarEntry(value: e)).toList(),
            borderColor: kBrand,
            fillColor: kBrand.withValues(alpha: 0.18),
            borderWidth: 2.5,
            entryRadius: compact ? 3 : 4,
          ),
        ],
      ),
    );
    // In-app chart gets side padding so labels never touch the card border
    final padded = compact
        ? chart
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16), child: chart);
    return height == null ? padded : SizedBox(height: height, child: padded);
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
// SHARE SERVICE + SHARE CARD
// ─────────────────────────────────────────────────────────────────────────────
class ShareService {
  static const playUrl =
      'https://play.google.com/store/apps/details?id=com.alignapp.adeseye';

  static String text(double pct, String grade, String lensLabel) =>
      'I scored ${pct.toStringAsFixed(0)}% (Grade $grade) on Align — $lensLabel. '
      'How aligned is your relationship?\n$playUrl';

  /// Captures the RepaintBoundary as a 1080px-wide PNG and opens the share sheet.
  static Future<void> shareCard({
    required GlobalKey boundaryKey,
    required String text,
  }) async {
    final ctx = boundaryKey.currentContext;
    if (ctx == null) throw StateError('Share card not mounted');
    final boundary = ctx.findRenderObject() as RenderRepaintBoundary;
    final ratio = 1080 / boundary.size.width; // always 1080 x 1920 output
    final ui.Image image = await boundary.toImage(pixelRatio: ratio);
    final ByteData? data =
        await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (data == null) throw StateError('PNG encode failed');
    final Uint8List bytes = data.buffer.asUint8List();

    await SharePlus.instance.share(
      ShareParams(
        text: text,
        files: [
          XFile.fromData(bytes, mimeType: 'image/png', name: 'align_result.png')
        ],
        fileNameOverrides: ['align_result.png'],
      ),
    );
  }
}

class ShareCard extends StatelessWidget {
  static const double width = 320;
  static const double height = 568; // 9:16 — Stories friendly

  final double percentage;
  final String grade;
  final Color gradeColor;
  final String lensLabel;
  final List<double> scores;

  const ShareCard({
    super.key,
    required this.percentage,
    required this.grade,
    required this.gradeColor,
    required this.lensLabel,
    required this.scores,
  });

  @override
  Widget build(BuildContext context) {
    // Ignore the user's system font scale so the captured image is consistent
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kBrandLight, kBackground],
          ),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/images/Align-Logo.png',
                  height: 44, fit: BoxFit.contain),
            ),
            const SizedBox(height: 12),
            const Text(
              'MY RELATIONSHIP ALIGNMENT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: kBrandDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(lensLabel,
                style: const TextStyle(fontSize: 12, color: kTextSub)),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: PillarRadarChart(
                    scores: scores, height: null, compact: true),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: gradeColor,
                    borderRadius: BorderRadius.circular(16),
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
                const SizedBox(width: 16),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: gradeColor,
                    letterSpacing: -1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'How aligned is your relationship?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Free 2-minute assessment on Google Play',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: kTextSub),
            ),
          ],
        ),
      ),
    );
  }
}

class ShareCardPage extends StatefulWidget {
  final double percentage;
  final String grade;
  final Color gradeColor;
  final String lensLabel;
  final List<double> scores;

  const ShareCardPage({
    super.key,
    required this.percentage,
    required this.grade,
    required this.gradeColor,
    required this.lensLabel,
    required this.scores,
  });

  @override
  State<ShareCardPage> createState() => _ShareCardPageState();
}

class _ShareCardPageState extends State<ShareCardPage> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _ready = false;
  bool _sharing = false;
  bool _precacheStarted = false;

  String get _text =>
      ShareService.text(widget.percentage, widget.grade, widget.lensLabel);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precacheStarted) return;
    _precacheStarted = true;
    // Make sure the logo is decoded before the user can capture the card
    precacheImage(const AssetImage('assets/images/Align-Logo.png'), context)
        .catchError((_) {})
        .whenComplete(() {
      if (mounted) setState(() => _ready = true);
    });
  }

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      await ShareService.shareCard(boundaryKey: _boundaryKey, text: _text);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not create the image. Sharing text instead.'),
            backgroundColor: kScoreAmber,
          ),
        );
      }
      await SharePlus.instance.share(ShareParams(text: _text));
    }
    if (mounted) setState(() => _sharing = false);
  }

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
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: RepaintBoundary(
                      key: _boundaryKey,
                      child: ShareCard(
                        percentage: widget.percentage,
                        grade: widget.grade,
                        gradeColor: widget.gradeColor,
                        lensLabel: widget.lensLabel,
                        scores: widget.scores,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: AlignButton(
                      label: _sharing ? 'Preparing...' : 'Share Image',
                      icon: Icons.share_rounded,
                      onPressed: (_ready && !_sharing) ? _share : null,
                    ),
                  ),
                  TextButton(
                    onPressed: _sharing
                        ? null
                        : () =>
                            SharePlus.instance.share(ShareParams(text: _text)),
                    child: const Text('Share text only',
                        style: TextStyle(fontSize: 13, color: kTextSub)),
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

// ─────────────────────────────────────────────────────────────────────────────
// PARTNER COMPARE — share code (no accounts, no backend)
// ─────────────────────────────────────────────────────────────────────────────
class PartnerCode {
  final Lens lens;
  final List<double> scores;
  const PartnerCode(this.lens, this.scores);

  static String _body(Lens lens, List<double> scores) {
    final letter = lens == Lens.feminine
        ? 'F'
        : lens == Lens.masculine
            ? 'M'
            : 'U';
    final b = StringBuffer(letter);
    for (final s in scores) {
      final v = s.round();
      b.write(v >= 10 ? 'A' : v.toString());
    }
    return b.toString();
  }

  static int _check(String body) {
    var sum = 0;
    for (var i = 0; i < body.length; i++) {
      sum += (i + 1) * body.codeUnitAt(i);
    }
    return sum % 97;
  }

  /// e.g. ALIGN-U5A37234-42
  static String encode(Lens lens, List<double> scores) {
    final body = _body(lens, scores);
    return 'ALIGN-$body-${_check(body).toString().padLeft(2, '0')}';
  }

  /// Finds a code anywhere inside pasted text. Returns null if invalid.
  static PartnerCode? decode(String input) {
    final m = RegExp(r'ALIGN-([UFM][0-9A]{7})-(\d{2})', caseSensitive: false)
        .firstMatch(input);
    if (m == null) return null;
    final body = m.group(1)!.toUpperCase();
    final check = int.parse(m.group(2)!);
    if (_check(body) != check) return null;
    final lens = body[0] == 'F'
        ? Lens.feminine
        : body[0] == 'M'
            ? Lens.masculine
            : Lens.universal;
    final scores = <double>[];
    for (var i = 1; i < body.length; i++) {
      final c = body[i];
      scores.add(c == 'A' ? 10.0 : double.parse(c));
    }
    return PartnerCode(lens, scores);
  }
}

class PartnerComparePage extends StatefulWidget {
  final List<double> myScores;
  final Lens myLens;
  final bool isPremium;

  const PartnerComparePage({
    super.key,
    required this.myScores,
    required this.myLens,
    required this.isPremium,
  });

  @override
  State<PartnerComparePage> createState() => _PartnerComparePageState();
}

class _PartnerComparePageState extends State<PartnerComparePage> {
  final TextEditingController _controller = TextEditingController();
  PartnerCode? _partner;
  String? _error;
  late bool _premium;
  final GlobalKey _resultKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _premium = widget.isPremium;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _lensName(Lens l) => l.name[0].toUpperCase() + l.name.substring(1);

  String _gapLabel(double g) =>
      g <= 1 ? 'In sync' : (g <= 3 ? 'Some gap' : 'Big gap');

  Color _gapColor(double g) =>
      g <= 1 ? kScoreGreen : (g <= 3 ? kScoreAmber : kScoreRed);

  String _matchBand(double m) {
    if (m >= 85) return 'You see this relationship very similarly.';
    if (m >= 70) return 'You mostly see eye to eye, with a few differences.';
    if (m >= 55) {
      return 'You see some things differently. That is worth talking about.';
    }
    return 'You see this relationship quite differently. A calm conversation is a good next step.';
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final text = data?.text;
    if (text == null || text.trim().isEmpty) {
      setState(
          () => _error = "Nothing to paste. Copy your partner's code first.");
      return;
    }
    _controller.text = text;
    _compare();
  }

  void _compare() {
    final decoded = PartnerCode.decode(_controller.text);
    if (decoded == null) {
      setState(() {
        _partner = null;
        _error = 'That code does not look right. Check it and try again.';
      });
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _partner = decoded;
      _error = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _resultKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _openPaywall() async {
    final purchased = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PaywallPage()),
    );
    if (purchased == true && mounted) setState(() => _premium = true);
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12, color: kTextSub)),
      ],
    );
  }

  List<Widget> _buildResult(PartnerCode partner) {
    final mine = widget.myScores;
    final theirs = partner.scores;
    final gaps = List<double>.generate(
        pillars.length, (i) => (mine[i] - theirs[i]).abs());
    final totalGap = gaps.reduce((a, b) => a + b);
    final match = (1 - totalGap / (pillars.length * 10)) * 100;
    final maxGap = gaps.reduce((a, b) => a > b ? a : b);
    final biggest = gaps.indexOf(maxGap);
    final matchColor =
        match >= 70 ? kScoreGreen : (match >= 55 ? kScoreAmber : kScoreRed);

    return [
      AlignCard(
        color: kBrandLight,
        child: Row(
          children: [
            Text(
              '${match.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w800,
                color: matchColor,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How closely you agree',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kBrandDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _matchBand(match),
                    style: const TextStyle(
                        fontSize: 13, color: kTextSub, height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'This shows how closely your scores match, not how strong the relationship is.',
                    style:
                        TextStyle(fontSize: 11.5, color: kTextSub, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      AlignCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeading('Your shapes side by side'),
            PillarRadarChart(scores: mine, compareScores: theirs),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot(kBrand, 'You'),
                const SizedBox(width: 16),
                _legendDot(kLensFeminine, 'Partner'),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      AlignCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeading('Where to start'),
            Text(
              maxGap <= 1
                  ? 'You answered almost the same on every pillar. Keep checking in with each other.'
                  : '${pillars[biggest]} is where you see things most differently. Start your conversation there.',
              style: const TextStyle(
                  fontSize: 14, color: kTextPrimary, height: 1.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'A gap is not a verdict. It shows where a conversation could help, so go gently.',
              style: TextStyle(fontSize: 12.5, color: kTextSub, height: 1.5),
            ),
          ],
        ),
      ),
      if (partner.lens != widget.myLens) ...[
        const SizedBox(height: 14),
        AlignCard(
          color: kBrandLight,
          padding: const EdgeInsets.all(14),
          child: Text(
            'You used different lenses (${_lensName(widget.myLens)} and ${_lensName(partner.lens)}). '
            'The scores are still comparable, but the questions were framed differently for each of you.',
            style:
                const TextStyle(fontSize: 12.5, color: kBrandDark, height: 1.5),
          ),
        ),
      ],
      const SizedBox(height: 14),
      if (_premium) _buildBreakdown(mine, theirs, gaps) else _buildLocked(),
    ];
  }

  Widget _buildBreakdown(
      List<double> mine, List<double> theirs, List<double> gaps) {
    return AlignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading('Pillar by pillar'),
          ...List.generate(pillars.length, (i) {
            final g = gaps[i];
            final bothLow = g <= 1 && mine[i] <= 4 && theirs[i] <= 4;
            final chipLabel = bothLow ? 'Both low' : _gapLabel(g);
            final chipColor = bothLow ? kScoreRed : _gapColor(g);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pillars[i],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: kTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'You ${mine[i].round()}  ·  Partner ${theirs[i].round()}',
                          style: const TextStyle(fontSize: 12, color: kTextSub),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: chipColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      chipLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: chipColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLocked() {
    return AlignCard(
      color: const Color(0xFFFDF9F0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            'See the full breakdown',
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700, color: kTextPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pillar-by-pillar scores for both of you, with a clear read on every gap.',
            style: TextStyle(fontSize: 13, color: kTextSub, height: 1.5),
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
              onPressed: _openPaywall,
              child: const Text(
                'View Plans',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const Text(
              'Compare with your partner',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Paste the code your partner shared from their results screen. You can compare because you have finished your own assessment.",
              style: TextStyle(fontSize: 14, color: kTextSub, height: 1.5),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 3,
              autocorrect: false,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                labelText: "Your partner's code",
                hintText: 'ALIGN-U5A37234-42',
                labelStyle: const TextStyle(color: kTextSub),
                filled: true,
                fillColor: kSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBrand, width: 2),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kScoreRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kScoreRed.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: kScoreRed, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(fontSize: 13, color: kScoreRed),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: AlignButton(
                label: 'Compare',
                icon: Icons.compare_arrows_rounded,
                onPressed: _compare,
              ),
            ),
            Center(
              child: TextButton(
                onPressed: _paste,
                child: const Text(
                  'Paste from clipboard',
                  style: TextStyle(fontSize: 13, color: kBrand),
                ),
              ),
            ),
            if (_partner != null) ...[
              SizedBox(key: _resultKey, height: 12),
              ..._buildResult(_partner!),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PILLAR GUIDES — diagnosis (free) + 7-day action plan (Pro)
// ─────────────────────────────────────────────────────────────────────────────
class PlanDay {
  final String title;
  final String task;
  const PlanDay(this.title, this.task);
}

class PillarGuide {
  final String planTitle;
  final String diagnosis; // free
  final String startHere; // free, one line
  final List<PlanDay> days; // Pro, exactly 7
  const PillarGuide({
    required this.planTitle,
    required this.diagnosis,
    required this.startHere,
    required this.days,
  });
}

// Index order MUST match the `pillars` list:
// Trust, Respect, Emotional Support, Shared Values, Communication,
// Physical Intimacy, Future Alignment
const List<PillarGuide> kPillarGuides = [
  // 0 — TRUST
  PillarGuide(
    planTitle: 'Rebuilding Trust',
    diagnosis:
        "Trust is the foundation the other pillars stand on. When it scores lowest, it usually means words and actions do not always match, or it does not feel fully safe to be honest. Small, repeated reliability does more to repair it than one big gesture.",
    startHere:
        "Make one small promise today, however minor, and keep it exactly.",
    days: [
      PlanDay("Name what trust means",
          "Write down three things that would make you feel more trusting, and three things you can offer. Keep them specific, like 'tell me when plans change', not 'be more honest'."),
      PlanDay("Keep one small promise",
          "Pick one small commitment and do it exactly when you said you would. Reliability in small things is how trust is rebuilt."),
      PlanDay("Share something unpolished",
          "Tell your partner one thing you would normally keep to yourself, such as a worry or a small mistake. Choose something low risk and say it without defending yourself."),
      PlanDay("Respond without defending",
          "When your partner shares a concern today, reply with 'Thank you for telling me' before anything else. Wait a full breath before explaining or disagreeing."),
      PlanDay("Be open about your day",
          "Share where you were and who you spoke to in a relaxed way, not as a report. Openness freely given builds more trust than answers demanded."),
      PlanDay("Repair one past hurt",
          "Choose one past moment that damaged trust. Acknowledge it in a sentence or two, say what you would do differently, and do not ask for forgiveness yet."),
      PlanDay("Review and renew",
          "Look back at the week. Tell each other one thing that felt safer and one thing that still feels uncertain, then agree on one promise for next week."),
    ],
  ),

  // 1 — RESPECT
  PillarGuide(
    planTitle: "Restoring Respect",
    diagnosis:
        "Respect shows up in tone, interruptions and how you speak about each other to other people. A low score often points to criticism, dismissiveness or feeling talked down to, even when no one means harm. It usually recovers quickly once the daily habits change.",
    startHere:
        "Today, do not interrupt once. Let every sentence finish before you reply.",
    days: [
      PlanDay("Spot the small slights",
          "Notice moments today when either of you rolls eyes, sighs, interrupts or mocks. Just count them without commenting. Awareness is the first step."),
      PlanDay("Soften the opening",
          "Start any difficult topic with 'I feel... when... I would like...'. Avoid 'you always' and 'you never'."),
      PlanDay("Say one thing you admire",
          "Tell your partner one specific thing you respect about them, with an example. 'I respect how you handled that call' lands better than 'you are great'."),
      PlanDay("Speak well of each other",
          "Today, mention your partner to friends or family only in a way you would be comfortable with them overhearing."),
      PlanDay("Ask before assuming",
          "Before reacting to something that bothered you, ask 'Can you help me understand why?' and listen to the full answer."),
      PlanDay("Honour a boundary",
          "Ask what boundary or preference of theirs you have been brushing aside. Agree to respect it, and ask for one of yours in return."),
      PlanDay("Weekly respect check",
          "Tell each other when you felt most respected this week and when you felt least. Agree on one habit each to keep or change."),
    ],
  ),

  // 2 — EMOTIONAL SUPPORT
  PillarGuide(
    planTitle: "Showing Up for Each Other",
    diagnosis:
        "Emotional support is feeling that your partner is on your side when things are hard. A low score often means one or both of you cope alone, miss each other's cues, or offer advice when what was wanted was understanding.",
    startHere:
        "Next time your partner shares a problem, ask: 'Do you want solutions or just someone to listen?'",
    days: [
      PlanDay("Ask and listen",
          "Ask 'How are you really doing?' and listen for five minutes without fixing, advising or switching to your own story."),
      PlanDay("Notice the bids",
          "A bid is a small request for attention, like a sigh, a comment or a 'look at this'. Notice them today and turn towards each one, even briefly."),
      PlanDay("Name the need",
          "Tell your partner one thing that would help you feel supported this week. Be concrete: 'ask me about my day' beats 'be more supportive'."),
      PlanDay("Offer comfort, not a fix",
          "When your partner is stressed, say 'That sounds hard. I am here.' Offer advice only if they ask for it."),
      PlanDay("Do one caring task",
          "Take over one chore or task that is weighing on your partner today, without being asked and without mentioning it afterwards."),
      PlanDay("Share a vulnerable moment",
          "Tell your partner about something that made you feel anxious, sad or unsure recently. Let them respond without trying to solve it."),
      PlanDay("Debrief the week",
          "Share when you felt most supported this week and when you felt alone. Agree on one thing each to do differently."),
    ],
  ),

  // 3 — SHARED VALUES
  PillarGuide(
    planTitle: "Finding Common Ground",
    diagnosis:
        "Shared values are the beliefs and priorities that guide big decisions, like money, family, faith and how you spend your time. A low score does not mean you must agree on everything. It usually means these things have not been talked about openly, or the differences feel risky to raise.",
    startHere:
        "Each write down your top three life priorities, then compare lists without judging.",
    days: [
      PlanDay("List your top five values",
          "Separately, write the five things that matter most to you, such as family, honesty, security, adventure, faith or growth. Do not share yet."),
      PlanDay("Compare your lists",
          "Swap lists and talk about where they overlap and where they differ. For each difference, ask 'Tell me more about why this matters to you'."),
      PlanDay("Talk about money",
          "Discuss one money question you have not fully talked through, such as saving, spending or helping family. Aim to understand, not to win."),
      PlanDay("Talk about family and home",
          "Share what you each want from family, friends and home life, including how much time with others and how much just for the two of you."),
      PlanDay("Find three shared values",
          "From your lists, pick three values you share. Write one sentence each on how you already live them out together."),
      PlanDay("Respect one difference",
          "Choose one value you hold differently. Agree how each of you can honour it without the other having to change."),
      PlanDay("Set a shared principle",
          "Agree on one principle to guide decisions this month, such as 'we decide big purchases together'. Write it down where you both see it."),
    ],
  ),

  // 4 — COMMUNICATION
  PillarGuide(
    planTitle: "Talking and Listening Better",
    diagnosis:
        "Communication is how every other pillar gets worked out. A low score often means important things go unsaid, conversations turn into arguments, or one of you shuts down. These habits are learnable and show results quickly.",
    startHere:
        "Before replying in any discussion today, repeat back what you heard: 'So you are saying...'.",
    days: [
      PlanDay("Twenty minutes, no phones",
          "Set aside twenty minutes with no screens to talk about something other than logistics or problems. Ask open questions like 'What was the best part of your day?'."),
      PlanDay("Reflect before replying",
          "In every conversation today, summarise what your partner said before you respond. Ask 'Did I get that right?'."),
      PlanDay("Use a soft start",
          "Raise one small issue using this pattern: 'I feel [emotion] about [situation]. I would like [request].' Keep it to one issue and one request."),
      PlanDay("Take a timeout properly",
          "Agree on a signal for pausing a heated moment. Take twenty minutes apart to calm down, then return and continue. Never use it to avoid the topic."),
      PlanDay("Say the unsaid thing",
          "Share one thing you have been holding back, kindly and calmly. Begin with 'This is hard to say, but it matters to me.'"),
      PlanDay("Appreciate out loud",
          "Thank your partner for three specific things today. Appreciation makes hard conversations easier."),
      PlanDay("Plan a weekly check-in",
          "Agree on a fixed twenty-minute weekly slot to talk about what is working, what is not and what you need. Put it in both calendars."),
    ],
  ),

  // 5 — PHYSICAL INTIMACY
  PillarGuide(
    planTitle: "Reconnecting Physically",
    diagnosis:
        "Physical intimacy covers affection, touch and sex. A low score often reflects stress, mismatched needs or a loss of everyday affection, not a lack of love. It is also the pillar couples find hardest to discuss, so starting the conversation is half the work.",
    startHere:
        "Offer a 20-second hug today, without it needing to lead to anything else.",
    days: [
      PlanDay("Everyday touch",
          "Add small, non-sexual touch today: a hand on the back, holding hands, a long hug. No pressure for it to go anywhere."),
      PlanDay("Say what feels good",
          "Tell your partner one kind of touch or affection you enjoy and would like more of. Keep it positive and specific."),
      PlanDay("Ask about their needs",
          "Ask 'What would make you feel more connected to me physically?' Listen without defending or promising anything yet."),
      PlanDay("Create the conditions",
          "Plan one low-stress evening: phones away, no chores, something relaxing. Connection is easier when neither of you is rushed or tired."),
      PlanDay("Talk about pace and comfort",
          "Agree how you will signal 'yes', 'not now' or 'slower'. A clear, safe way to say no makes it easier to say yes."),
      PlanDay("Try something new together",
          "Choose a low-pressure new way to be close, like a massage or a slow dance. Agree beforehand that either of you can stop at any time."),
      PlanDay("Review how it felt",
          "Share what felt good this week and what you would like next. Agree on one small habit of daily affection to keep."),
    ],
  ),

  // 6 — FUTURE ALIGNMENT
  PillarGuide(
    planTitle: "Building a Shared Future",
    diagnosis:
        "Future alignment is whether you are heading in the same direction on the big things: where you live, children, careers, money and the kind of life you want. A low score often means these topics have been avoided, or that you are assuming you want the same things.",
    startHere:
        "Each finish this sentence, then compare: 'In five years I would love our life to look like...'",
    days: [
      PlanDay("Picture five years ahead",
          "Separately, write a few lines on where you want to live, work and spend your time in five years. Do not share yet."),
      PlanDay("Share your pictures",
          "Read your answers aloud to each other. Highlight what matches, what is close and what is different."),
      PlanDay("Talk about the big decisions",
          "Discuss one major decision you may face, such as marriage, children, moving or a career change. Say what you want and why, and listen to the same from your partner."),
      PlanDay("Find the overlap",
          "List three things you both want in the future. Make them concrete, like 'own a home' or 'travel once a year'."),
      PlanDay("Name one non-negotiable",
          "Each share one thing you cannot compromise on and one thing you are flexible about. Explain why, and acknowledge your partner's answer without arguing."),
      PlanDay("Take one small step",
          "Pick one shared goal and take a first action today, like opening a savings pot, booking a visit or researching a move."),
      PlanDay("Set a quarterly check-in",
          "Agree a date within the next three months to review your goals together. Plans change, so what matters is staying in the conversation."),
    ],
  ),
];

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
  bool _loadingPremium = true;
  bool _saved = false;
  late int _planIndex;

  // ── Focus-area helpers ──────────────────────────────────────────────────
  bool get _allEqual => widget.scores.every((s) => s == widget.scores.first);

  double get _lowestScore => widget.scores.reduce((a, b) => a < b ? a : b);

  int get _focusIndex => widget.scores.indexOf(_lowestScore);

  List<int> get _lowestIndexes => [
        for (int i = 0; i < widget.scores.length; i++)
          if (widget.scores[i] == _lowestScore) i
      ];

  @override
  void initState() {
    super.initState();
    _planIndex = _allEqual ? 0 : _focusIndex;
    _loadPremium();
    _saveAssessment();
  }

  Future<void> _loadPremium() async {
    if (kDebugMode) {
      setState(() {
        isPremium = true;
        _loadingPremium = false;
      });
      return;
    }
    try {
      isPremium = await PremiumService.isPremium()
          .timeout(const Duration(seconds: 5), onTimeout: () => false);
    } catch (_) {
      isPremium = false;
    }
    setState(() => _loadingPremium = false);
  }

  Future<void> _saveAssessment() async {
    if (!AuthService.isSignedIn) return;
    final lensString = widget.lens.name;
    final saved = await AssessmentService.save(
      lens: lensString,
      scores: widget.scores,
      overallScore: widget.percentage,
      grade: grade,
    );
    if (saved) setState(() => _saved = true);
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

  String get gradeDescription {
    switch (grade) {
      case 'A':
        return 'Strongly aligned. Protect what is working and keep investing in it.';
      case 'B':
        return 'A healthy foundation with room to grow. A few focused changes will lift it further.';
      case 'C':
        return 'Alignment is uneven. Intentional effort will make a real difference.';
      case 'D':
        return 'Several areas need attention. An honest conversation is the place to start.';
      default:
        return 'This relationship is under real strain. Consider talking it through with your partner or a qualified professional.';
    }
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
      body: _loadingPremium
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: kBrand),
                  SizedBox(height: 16),
                  Text('Loading your results...',
                      style: TextStyle(color: kTextSub, fontSize: 14)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // ── SAVED INDICATOR ──────────────────────────────────────────
                if (_saved)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 14, color: kBrand.withValues(alpha: 0.7)),
                        const SizedBox(width: 6),
                        Text(
                          'Assessment saved to your history',
                          style: TextStyle(
                              fontSize: 12,
                              color: kBrand.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),

                // ── SIGN IN PROMPT ───────────────────────────────────────────
                if (!AuthService.isSignedIn)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (_) => const AuthPage()),
                        );
                        if (result == true) {
                          setState(() {});
                          _saveAssessment();
                        }
                      },
                      child: AlignCard(
                        color: kBrandLight,
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: const [
                            Icon(Icons.history_rounded,
                                color: kBrand, size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Sign in to save this result and track your progress',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: kBrandDark,
                                    height: 1.4),
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: kBrand, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ── SCORE HERO CARD ──────────────────────────────────────────
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
                              InsightEngine.overall(
                                  widget.percentage, widget.lens),
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
                              style: const TextStyle(
                                  fontSize: 11, color: kTextSub)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ── GRADE DESCRIPTION BANNER ─────────────────────────────────
                AlignCard(
                  color: gradeColor == kScoreGreen
                      ? kBrandLight
                      : gradeColor.withValues(alpha: 0.08),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    'Grade $grade — $gradeDescription',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                      color:
                          gradeColor == kScoreGreen ? kBrandDark : kTextPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── FREE RADAR ───────────────────────────────────────────────
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

                // ── KEY OBSERVATIONS ─────────────────────────────────────────
                AlignCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeading('Key Observations'),
                      if (maxScore == minScore)
                        _observationRow(
                          Icons.balance_rounded,
                          kBrand,
                          InsightEngine.evenly(maxScore),
                        )
                      else ...[
                        _observationRow(
                          Icons.arrow_upward_rounded,
                          kScoreGreen,
                          InsightEngine.strongest(
                            pillars[widget.scores.indexOf(maxScore)],
                            maxScore,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _observationRow(
                          Icons.arrow_downward_rounded,
                          kScoreRed,
                          InsightEngine.weakest(
                            pillars[widget.scores.indexOf(minScore)],
                            minScore,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── FOCUS AREA (free) ────────────────────────────────────────
                _buildFocusCard(),
                const SizedBox(height: 14),

                // ── PREMIUM CONTENT ──────────────────────────────────────────
                if (isPremium) ...[
                  _buildPlanCard(),
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
                        ...PremiumInsightEngine.buildPillarStability(
                            widget.scores),
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

                // ── PREMIUM LOCK CARD ────────────────────────────────────────
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
                            Text(
                              _allEqual
                                  ? 'Unlock your full analysis'
                                  : 'Unlock your 7-day plan for ${pillars[_focusIndex]}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: kTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Get your exact pillar scores, alignment distribution, '
                              'stability ratings, a deep structural insight and a '
                              '7-day action plan for every pillar.',
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  final purchased = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const PaywallPage()),
                                  );
                                  if (purchased == true) {
                                    setState(() => isPremium = true);
                                  }
                                },
                                child: const Text(
                                  'View Plans',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700),
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
                            color: kPremiumGold.withValues(alpha: 0.5),
                            size: 22),
                      ),
                    ],
                  ),

                if (!isPremium && !kDebugMode) const SizedBox(height: 14),

                // ── PARTNER COMPARE ──────────────────────────────────────────
                _buildPartnerCard(),
                const SizedBox(height: 14),

                // ── SHARE ────────────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: AlignButton(
                    label: 'Share My Result',
                    icon: Icons.share_rounded,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShareCardPage(
                            percentage: widget.percentage,
                            grade: grade,
                            gradeColor: gradeColor,
                            lensLabel: lensLabel,
                            scores: widget.scores,
                          ),
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

  // FREE — names the weakest pillar and gives one starting step
  Widget _buildFocusCard() {
    if (_allEqual) {
      return const AlignCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeading('Your Focus Area'),
            Text(
              'You rated every pillar the same, so there is no single weak spot. '
              'Pick the pillar that matters most to you and start there.',
              style: TextStyle(fontSize: 14, color: kTextPrimary, height: 1.5),
            ),
          ],
        ),
      );
    }
    final idx = _focusIndex;
    final guide = kPillarGuides[idx];
    final also =
        _lowestIndexes.where((i) => i != idx).map((i) => pillars[i]).toList();

    return AlignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading('Your Focus Area: ${pillars[idx]}'),
          Text(
            guide.diagnosis,
            style:
                const TextStyle(fontSize: 14, color: kTextPrimary, height: 1.5),
          ),
          if (also.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Also scored equally low: ${also.join(', ')}.',
                style: const TextStyle(fontSize: 13, color: kTextSub),
              ),
            ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kBrand.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'START HERE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: kBrandDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  guide.startHere,
                  style: const TextStyle(
                      fontSize: 14, color: kBrandDark, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // PRO — full 7-day plan, any pillar selectable
  Widget _buildPlanCard() {
    final guide = kPillarGuides[_planIndex];
    return AlignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading('7-Day Action Plan'),
          Wrap(
            spacing: 6,
            runSpacing: 2,
            children: List.generate(pillars.length, (i) {
              final selected = i == _planIndex;
              return ChoiceChip(
                label: Text(kShortPillars[i]),
                selected: selected,
                showCheckmark: false,
                labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onSelected: (_) => setState(() => _planIndex = i),
                selectedColor: kBrand,
                backgroundColor: kSurface,
                side: BorderSide(color: selected ? kBrand : kBorder),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? kSurface : kTextPrimary,
                ),
              );
            }),
          ),
          if (!_allEqual)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Your lowest pillar is selected first. Tap any pillar to see its plan.',
                style: TextStyle(fontSize: 11, color: kTextSub, height: 1.4),
              ),
            ),
          const SizedBox(height: 14),
          Text(
            guide.planTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kBrandDark,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(guide.days.length, (d) {
            final day = guide.days[d];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kBrand.withValues(alpha: 0.12),
                    ),
                    child: Center(
                      child: Text(
                        '${d + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: kBrand,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          day.task,
                          style: const TextStyle(
                              fontSize: 13, color: kTextSub, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kBrandLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'These exercises are for relationships where you both feel safe. '
              'If you ever feel afraid, controlled or unsafe, skip them and '
              'reach out to a qualified professional or a local support service.',
              style: TextStyle(fontSize: 11.5, color: kBrandDark, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  void _shareMyCode() {
    final code = PartnerCode.encode(widget.lens, widget.scores);
    SharePlus.instance.share(
      ShareParams(
        text:
            "Let's compare our relationship results on Align. My code: $code\n\n"
            "Take the free assessment, then tap 'Compare with your partner' on your results screen and enter my code.\n"
            "${ShareService.playUrl}",
      ),
    );
  }

  Future<void> _openCompare() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PartnerComparePage(
          myScores: widget.scores,
          myLens: widget.lens,
          isPremium: isPremium,
        ),
      ),
    );
    if (mounted) _loadPremium();
  }

  Widget _buildPartnerCard() {
    return AlignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading('Compare with your partner'),
          const Text(
            "Each of you takes the assessment, then you swap codes. You only see each other's results once you have both finished.",
            style: TextStyle(fontSize: 13, color: kTextSub, height: 1.5),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your code contains your seven pillar scores, so only share it with your partner.',
            style: TextStyle(fontSize: 12, color: kTextSub, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: AlignButton(
              label: 'Share my code',
              icon: Icons.share_rounded,
              onPressed: _shareMyCode,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: AlignButton(
              label: "Enter partner's code",
              icon: Icons.people_alt_outlined,
              outline: true,
              onPressed: _openCompare,
            ),
          ),
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
// PREMIUM SERVICE — RevenueCat
// ─────────────────────────────────────────────────────────────────────────────
class PremiumService {
  static const _apiKey = kReleaseMode
      ? 'goog_PpWkcNjCqsaqoAuNHFCzlBuYfkK'
      : 'test_mIZCjyeqBNBaAtTTrqnBzcwuSeT';
  static const _entitlement = 'pro_access';

  static Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.debug);
    final config = PurchasesConfiguration(_apiKey);
    await Purchases.configure(config);
  }

  static Future<bool> isPremium() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(_entitlement);
    } catch (_) {
      return false;
    }
  }

  static Future<List<Package>> getPackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      return (offerings.getOffering('premium') ?? offerings.current)
              ?.availablePackages ??
          [];
    } catch (_) {
      return [];
    }
  }

  static Future<bool> purchase(Package package) async {
    try {
      await Purchases.purchasePackage(package);
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(_entitlement);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> restore() async {
    try {
      final info = await Purchases.restorePurchases();
      return info.entitlements.active.containsKey(_entitlement);
    } catch (_) {
      return false;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAYWALL PAGE
// ─────────────────────────────────────────────────────────────────────────────
class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  List<Package> _packages = [];
  bool _loading = true;
  bool _purchasing = false;
  int _selectedIndex = 0;

  static const Map<String, String> _labels = {
    'monthly': 'Monthly',
    'quarterly': 'Quarterly',
    'biannual': 'Bi-Annual',
    'yearly': 'Annual',
  };

  static const Map<String, String> _descriptions = {
    'monthly': 'Billed every month',
    'quarterly': 'Billed every 3 months',
    'biannual': 'Billed every 6 months',
    'yearly': 'Billed once a year — best value',
  };

  static const Map<String, String> _badges = {
    'yearly': 'BEST VALUE',
    'biannual': 'POPULAR',
  };

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    final packages = await PremiumService.getPackages()
        .timeout(const Duration(seconds: 5), onTimeout: () => []);
    const order = ['monthly', 'quarterly', 'biannual', 'yearly'];
    packages.sort((a, b) {
      final ai = order.indexOf(a.storeProduct.identifier.split(':')[0]);
      final bi = order.indexOf(b.storeProduct.identifier.split(':')[0]);
      return ai.compareTo(bi);
    });
    final yearlyIndex = packages
        .indexWhere((p) => p.storeProduct.identifier.split(':')[0] == 'yearly');
    setState(() {
      _packages = packages;
      _selectedIndex = yearlyIndex >= 0 ? yearlyIndex : 0;
      _loading = false;
    });
  }

  Future<void> _purchase() async {
    if (_packages.isEmpty) return;
    setState(() => _purchasing = true);
    final success = await PremiumService.purchase(_packages[_selectedIndex]);
    setState(() => _purchasing = false);
    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase could not be completed. Please try again.'),
          backgroundColor: kScoreRed,
        ),
      );
    }
  }

  Future<void> _restore() async {
    setState(() => _purchasing = true);
    final restored = await PremiumService.restore();
    setState(() => _purchasing = false);
    if (restored && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active subscription found to restore.'),
          backgroundColor: kScoreAmber,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
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
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kBrand))
          : SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Align Pro',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Unlock your full relationship analysis.',
                      style: TextStyle(fontSize: 15, color: kTextSub),
                    ),
                    const SizedBox(height: 20),
                    AlignCard(
                      color: kBrandLight,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: const [
                          _FeatureRow(
                              icon: Icons.bar_chart_rounded,
                              text:
                                  'Exact Pillar Scores & Alignment Distribution'),
                          _FeatureRow(
                              icon: Icons.verified_rounded,
                              text: 'Pillar Stability Ratings'),
                          _FeatureRow(
                              icon: Icons.insights_rounded,
                              text: 'Deep Structural Insight'),
                          _FeatureRow(
                              icon: Icons.checklist_rounded,
                              text: '7-Day Action Plan for Every Pillar'),
                          _FeatureRow(
                              icon: Icons.show_chart_rounded,
                              text:
                                  'Progress Graph — Day, Week, Month & Year views'),
                          _FeatureRow(
                              icon: Icons.history_rounded,
                              text: 'Full Assessment History'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_packages.isEmpty)
                      const Center(
                        child: Text(
                          'No plans available. Please check your connection.',
                          style: TextStyle(color: kTextSub),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      Column(
                        children: List.generate(_packages.length, (i) {
                          final pkg = _packages[i];
                          final id = pkg.storeProduct.identifier.split(':')[0];
                          final label = _labels[id] ?? id;
                          final desc = _descriptions[id] ?? '';
                          final badge = _badges[id];
                          final price = pkg.storeProduct.priceString;
                          final isSelected = i == _selectedIndex;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedIndex = i),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? kBrand.withValues(alpha: 0.07)
                                    : kSurface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? kBrand : kBorder,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? kBrand : kTextSub,
                                        width: 2,
                                      ),
                                      color: isSelected
                                          ? kBrand
                                          : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check,
                                            size: 13, color: kSurface)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              label,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: isSelected
                                                    ? kBrand
                                                    : kTextPrimary,
                                              ),
                                            ),
                                            if (badge != null) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 7,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: kPremiumGold,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  badge,
                                                  style: const TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w800,
                                                    color: kSurface,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        Text(
                                          desc,
                                          style: const TextStyle(
                                              fontSize: 12, color: kTextSub),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    price,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? kBrand : kTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPremiumGold,
                          foregroundColor: kSurface,
                          elevation: 2,
                          shadowColor: kPremiumGold.withValues(alpha: 0.4),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed:
                            _purchasing || _packages.isEmpty ? null : _purchase,
                        child: _purchasing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: kSurface,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Unlock Align Pro',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: _purchasing ? null : _restore,
                        child: const Text(
                          'Restore Purchases',
                          style: TextStyle(fontSize: 13, color: kTextSub),
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

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: kBrand),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 13,
                  color: kTextPrimary,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESET PASSWORD PAGE
// ─────────────────────────────────────────────────────────────────────────────
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _errorMessage;
  bool _success = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      setState(() => _errorMessage = 'Please fill in both fields.');
      return;
    }
    if (password.length < 8) {
      setState(() => _errorMessage = 'Password must be at least 8 characters.');
      return;
    }
    if (password != confirm) {
      setState(
          () => _errorMessage = 'Passwords do not match. Please try again.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await supabase.auth.updateUser(UserAttributes(password: password));
      await supabase.auth.signOut();
      setState(() {
        _success = true;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Could not update password. Please request a new reset link.';
        _loading = false;
      });
    }
  }

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
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: _success ? _buildSuccess() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Set New Password',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: kTextPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Enter your new password below. Make sure it is at least 8 characters long.',
          style: TextStyle(fontSize: 14, color: kTextSub, height: 1.5),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'New Password',
            labelStyle: const TextStyle(color: kTextSub),
            filled: true,
            fillColor: kSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kBrand, width: 2),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: kTextSub,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _confirmController,
          obscureText: _obscureConfirm,
          decoration: InputDecoration(
            labelText: 'Confirm New Password',
            labelStyle: const TextStyle(color: kTextSub),
            filled: true,
            fillColor: kSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kBrand, width: 2),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: kTextSub,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kScoreRed.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kScoreRed.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: kScoreRed, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 13, color: kScoreRed),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: AlignButton(
            label: _loading ? 'Updating...' : 'Update Password',
            onPressed: _loading ? null : _updatePassword,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: kBrandLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: kBrand, size: 40),
        ),
        const SizedBox(height: 24),
        const Text(
          'Password Updated',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: kTextPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your password has been updated successfully. Please sign in with your new password.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: kTextSub, height: 1.5),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: AlignButton(
            label: 'Sign In',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const OnboardingPage()),
                (route) => false,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LEGAL PAGE BASE
// ─────────────────────────────────────────────────────────────────────────────
class _LegalPage extends StatelessWidget {
  final String title;
  final List<_LegalSection> sections;
  final String lastUpdated;

  const _LegalPage({
    required this.title,
    required this.sections,
    required this.lastUpdated,
  });

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
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Last updated: $lastUpdated',
            style: const TextStyle(fontSize: 12, color: kTextSub),
          ),
          const SizedBox(height: 24),
          ...sections.map((s) => _buildSection(s)),
          const SizedBox(height: 32),
          AlignCard(
            color: kBrandLight,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Questions or concerns?',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary),
                ),
                SizedBox(height: 4),
                Text(
                  'Contact us at:',
                  style: TextStyle(fontSize: 13, color: kTextSub),
                ),
                SizedBox(height: 2),
                Text(
                  'adebowale.adeseye.align@gmail.com',
                  style: TextStyle(
                      fontSize: 13, color: kBrand, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(_LegalSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.heading,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            section.body,
            style: const TextStyle(fontSize: 14, color: kTextSub, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _LegalSection {
  final String heading;
  final String body;
  const _LegalSection(this.heading, this.body);
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIVACY POLICY
// ─────────────────────────────────────────────────────────────────────────────
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalPage(
      title: 'Privacy Policy',
      lastUpdated: 'March 2026',
      sections: [
        _LegalSection(
          'Overview',
          'Align ("we", "our", or "us") is committed to protecting your privacy. '
              'This Privacy Policy explains how we collect, use, and safeguard your '
              'information when you use the Align mobile application.',
        ),
        _LegalSection(
          'Information We Collect',
          'Align is designed with your privacy in mind. We do not collect any '
              'personally identifiable information unless you choose to create an '
              'account. The assessment scores you enter are processed locally on '
              'your device and are not transmitted to our servers without your consent.\n\n'
              'If you subscribe to Align Pro, we collect payment information solely '
              'through RevenueCat, our payment processor. We do not store your payment '
              'details directly.',
        ),
        _LegalSection(
          'How We Use Your Information',
          'Any information collected is used solely to:\n'
              '• Provide and improve the Align app experience\n'
              '• Process your subscription and verify access to premium features\n'
              '• Save and sync your assessment history when you are signed in\n'
              '• Respond to your support requests\n\n'
              'We do not sell, trade, or share your personal information with '
              'third parties for marketing purposes.',
        ),
        _LegalSection(
          'Third-Party Services',
          'Align uses the following third-party services:\n\n'
              '• RevenueCat — for subscription management and payment processing.\n\n'
              '• Supabase — for user authentication and secure assessment history storage.\n\n'
              '• Google Play — for app distribution and in-app purchases on Android devices.',
        ),
        _LegalSection(
          'Data Retention',
          'Assessment data stored in your account is retained until you delete it '
              'or close your account. You may delete individual assessments at any time '
              'from the History screen. Subscription records are retained by RevenueCat '
              'in accordance with their data retention policies.',
        ),
        _LegalSection(
          'Age Restriction',
          'Align is intended for use by adults aged 18 and over. '
              'The app deals with adult relationship themes including physical intimacy '
              'and emotional maturity. We do not knowingly collect personal information '
              'from anyone under the age of 18. If you believe a minor has created an '
              'account, please contact us immediately.',
        ),
        _LegalSection(
          'Changes to This Policy',
          'We may update this Privacy Policy from time to time. We will notify '
              'you of any significant changes by updating the "Last updated" date '
              'at the top of this page. Continued use of the app after changes '
              'constitutes acceptance of the updated policy.',
        ),
        _LegalSection(
          'Contact Us',
          'If you have any questions about this Privacy Policy, please contact us at:\n'
              'adebowale.adeseye.align@gmail.com',
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TERMS OF SERVICE
// ─────────────────────────────────────────────────────────────────────────────
class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalPage(
      title: 'Terms of Service',
      lastUpdated: 'March 2026',
      sections: [
        _LegalSection(
          'Acceptance of Terms',
          'By downloading or using the Align app, you agree to be bound by '
              'these Terms of Service. If you do not agree to these terms, '
              'please do not use the app.',
        ),
        _LegalSection(
          'Description of Service',
          'Align is a self-reflection tool designed to help individuals assess '
              'and understand the alignment of their romantic relationships. '
              'Align is not a licensed counselling or therapy service and does not '
              'provide professional relationship advice.',
        ),
        _LegalSection(
          'Age Requirement',
          'Align is intended for use by adults aged 18 and over. '
              'By using this app, you confirm that you are at least 18 years of age. '
              'The app deals with adult relationship themes including physical intimacy, '
              'emotional vulnerability, and relationship health assessment. '
              'Use of this app by anyone under the age of 18 is strictly prohibited.',
        ),
        _LegalSection(
          'Important Disclaimer',
          'Align is a self-reflection and personal assessment tool only. '
              'The scores, grades, and insights generated by the app are based '
              'solely on the information you provide and are intended for '
              'personal reflection purposes only.\n\n'
              'Align does not replace professional relationship counselling, '
              'therapy, or advice. If you are experiencing serious relationship '
              'difficulties, emotional distress, or any form of abuse, please '
              'seek guidance from a qualified professional immediately.',
        ),
        _LegalSection(
          'Align Pro Subscription',
          'Align Pro is a paid subscription service that unlocks premium '
              'features within the app. Subscriptions are available on a monthly, '
              'quarterly, bi-annual, and annual basis.\n\n'
              '• Subscriptions automatically renew unless cancelled at least '
              '24 hours before the end of the current period.\n'
              '• Payment is charged to your Google Play account upon confirmation.\n'
              '• You may cancel your subscription at any time through your '
              'Google Play account settings.\n'
              '• Refunds are subject to Google Play\'s refund policy.',
        ),
        _LegalSection(
          'User Responsibilities',
          'You agree to use Align only for lawful purposes and in a manner '
              'that does not infringe the rights of others. You are responsible '
              'for maintaining the confidentiality of your account credentials '
              'and for all activities that occur under your account.',
        ),
        _LegalSection(
          'Intellectual Property',
          'All content, design, graphics, and code within the Align app are '
              'the property of Align and are protected by applicable intellectual '
              'property laws. You may not reproduce, distribute, or create '
              'derivative works without our express written permission.',
        ),
        _LegalSection(
          'Limitation of Liability',
          'To the fullest extent permitted by law, Align shall not be liable '
              'for any indirect, incidental, special, or consequential damages '
              'arising from your use of the app or reliance on any content '
              'or insights generated by the app.',
        ),
        _LegalSection(
          'Changes to Terms',
          'We reserve the right to modify these Terms of Service at any time. '
              'We will notify you of significant changes by updating the '
              '"Last updated" date. Continued use of the app after changes '
              'constitutes acceptance of the updated terms.',
        ),
        _LegalSection(
          'Contact Us',
          'If you have any questions about these Terms of Service, '
              'please contact us at:\n'
              'adebowale.adeseye.align@gmail.com',
        ),
      ],
    );
  }
}
