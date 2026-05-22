import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'dart:ui';
import 'dart:math' as math;
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    _fadeController.forward();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '813646770042-i97phgog7q394l248s9bthfcp55kjiab.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDocRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnapshot = await userDocRef.get();

        if (!docSnapshot.exists) {
          await userDocRef.set({
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName,
            'photoURL': user.photoURL,
            'selectedAi': 'deepseek',
            'apiKeys': {
              'deepseek': '',
              'openai': '',
            },
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        // --- SUPABASE UPSERT ---
        try {
          final supabaseClient = supabase.Supabase.instance.client;
          await supabaseClient.from('users').upsert({
            'id': user.uid,
            'email': user.email ?? '',
            'name': user.displayName ?? '',
            'avatar_url': user.photoURL ?? '',
          });
        } catch (supaErr) {
          debugPrint('Supabase upsert error: $supaErr');
        }
        // -----------------------

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Authentication Failed: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background gradient ──────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF040D1A), Color(0xFF071428), Color(0xFF0A1A35)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Radial glow — top-left blue ──────────────────────────────
          Positioned(
            top: -200,
            left: -200,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1E40AF).withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Radial glow — bottom-right teal ─────────────────────────
          Positioned(
            bottom: -180,
            right: -180,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0EA5E9).withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Grid dots overlay ────────────────────────────────────────
          Positioned.fill(
            child: CustomPaint(painter: _DotGridPainter()),
          ),

          // ── Main scrollable content ──────────────────────────────────
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),

                    // ── Brand badge ────────────────────────────────────
                    ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(12.0),
                        child: Image.asset('assets/images/logo_bg.jpeg', height: 90,)),

                    const SizedBox(height: 32),

                    // ── Floating feature badges ────────────────────────
                    AnimatedBuilder(
                      animation: _floatAnimation,
                      builder: (context, child) {
                        return SizedBox(
                          width: 620,
                          height: 56,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Left badge
                              Positioned(
                                left: 0,
                                top: 8 + (_floatAnimation.value * 0.6),
                                child: _FeatureBadge(
                                  color: const Color(0xFF38BDF8),
                                  label: 'No code required',
                                ),
                              ),
                              // Centre badge
                              Positioned(
                                top: -(_floatAnimation.value * 0.4),
                                child: _FeatureBadge(
                                  color: const Color(0xFF34D399),
                                  label: 'Publish instantly',
                                ),
                              ),
                              // Right badge
                              Positioned(
                                right: 0,
                                top: 8 + (_floatAnimation.value * 0.7),
                                child: _FeatureBadge(
                                  color: const Color(0xFFA78BFA),
                                  label: 'AI-powered UI',
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // ── Headline ───────────────────────────────────────
                    const Text(
                      'Create app and publish it',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'without code.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -1.0,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Sub-headline ───────────────────────────────────
                    Text(
                      'Build, launch, and scale your product —\nno engineering team needed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── Sign-in card ───────────────────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          width: 420,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 28),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B1D3A).withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF1E3A6E),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Card label
                              Text(
                                'SIGN IN TO YOUR ACCOUNT',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.35),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.5,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Google Sign-In Button
                              _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Color(0xFF38BDF8),
                                    )
                                  : SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: _handleGoogleSignIn,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor:
                                              const Color(0xFF111827),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          elevation: 0,
                                          shadowColor: Colors.transparent,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/icons/google.png',
                                              width: 22,
                                              height: 22,
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Continue with Google',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const DashboardScreen()),
                                  );
                                },
                                child: Text(
                                  'Skip for now',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Terms line
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.35),
                                    fontSize: 12,
                                    height: 1.6,
                                  ),
                                  children: [
                                    const TextSpan(
                                        text: 'By continuing you agree to our '),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(
                                        color: const Color(0xFF38BDF8)
                                            .withOpacity(0.85),
                                        decoration: TextDecoration.underline,
                                        decorationColor:
                                            const Color(0xFF38BDF8)
                                                .withOpacity(0.5),
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' · ',
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.2)),
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: const Color(0xFF38BDF8)
                                            .withOpacity(0.85),
                                        decoration: TextDecoration.underline,
                                        decorationColor:
                                            const Color(0xFF38BDF8)
                                                .withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Trust bar ──────────────────────────────────────
                    Text(
                      'Trusted by 12,000+ teams worldwide',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Stars
                        ...List.generate(4, (_) => const Icon(Icons.star,
                            color: Color(0xFFFBBF24), size: 18)),
                        const Icon(Icons.star_half,
                            color: Color(0xFFFBBF24), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '4.9 · 2,400+ reviews',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feature badge pill ────────────────────────────────────────────────────────
class _FeatureBadge extends StatelessWidget {
  final Color color;
  final String label;

  const _FeatureBadge({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1D3A).withOpacity(0.9),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFF1E3A6E), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subtle dot-grid background painter ───────────────────────────────────────
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 28.0;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeCap = StrokeCap.round;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
