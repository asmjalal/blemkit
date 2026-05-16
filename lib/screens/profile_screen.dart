import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  Map<String, dynamic>? _userData;
  bool _loadingData = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(
        parent: _fadeController, curve: Curves.easeOutCubic);
    _fadeController.forward();
    _fetchUserData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && mounted) {
          setState(() => _userData = doc.data());
        }
      } catch (_) {}
    }
    if (mounted) setState(() => _loadingData = false);
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign Out',
          style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to sign out of SynappKit?',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final selectedAi =
        (_userData?['selectedAi'] as String? ?? 'deepseek').toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFF040D1A),
      body: Stack(
        children: [
          // ── Background glows ──────────────────────────────────────────
          Positioned(
            top: -160,
            left: -160,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF1E40AF).withOpacity(0.2),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -120,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF0fadd5).withOpacity(0.15),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          FadeTransition(
            opacity: _fadeAnim,
            child: SafeArea(
              child: Column(
                children: [
                  // ── App bar row ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white70, size: 20),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      child: Column(
                        children: [
                          // ── Avatar card ──────────────────────────────
                          _GlassCard(
                            child: Column(
                              children: [
                                // Avatar
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Container(
                                      width: 88,
                                      height: 88,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF0fadd5),
                                          width: 2.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF0fadd5)
                                                .withOpacity(0.3),
                                            blurRadius: 20,
                                          )
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundImage:
                                            user?.photoURL != null
                                                ? NetworkImage(user!.photoURL!)
                                                : null,
                                        backgroundColor:
                                            const Color(0xFF0fadd5),
                                        child: user?.photoURL == null
                                            ? Text(
                                                (user?.displayName
                                                                ?.isNotEmpty ==
                                                            true
                                                        ? user!.displayName![0]
                                                        : user?.email?[0] ??
                                                            'U')
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF22C55E),
                                        border: Border.all(
                                            color: const Color(0xFF040D1A),
                                            width: 2),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  user?.displayName ?? 'SynappKit User',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ?? '',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.45),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Active badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E)
                                        .withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                        color: const Color(0xFF22C55E)
                                            .withOpacity(0.3)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.circle,
                                          size: 7,
                                          color: Color(0xFF22C55E)),
                                      SizedBox(width: 6),
                                      Text(
                                        'Active Account',
                                        style: TextStyle(
                                          color: Color(0xFF22C55E),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ── Account info ─────────────────────────────
                          _GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionLabel('Account Details'),
                                const SizedBox(height: 14),
                                _InfoRow(
                                    icon: Icons.person_outline,
                                    label: 'Name',
                                    value: user?.displayName ?? '—'),
                                const _Divider(),
                                _InfoRow(
                                    icon: Icons.email_outlined,
                                    label: 'Email',
                                    value: user?.email ?? '—'),
                                const _Divider(),
                                _InfoRow(
                                    icon: Icons.fingerprint,
                                    label: 'User ID',
                                    value: user?.uid != null
                                        ? '${user!.uid.substring(0, 8)}...'
                                        : '—'),
                                const _Divider(),
                                _InfoRow(
                                    icon: Icons.verified_user_outlined,
                                    label: 'Email Verified',
                                    value: user?.emailVerified == true
                                        ? 'Yes'
                                        : 'No',
                                    valueColor: user?.emailVerified == true
                                        ? const Color(0xFF22C55E)
                                        : Colors.orangeAccent),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ── AI config ────────────────────────────────
                          _GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionLabel('AI Configuration'),
                                const SizedBox(height: 14),
                                _loadingData
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                            color: Color(0xFF0fadd5),
                                            strokeWidth: 2))
                                    : _InfoRow(
                                        icon: Icons.auto_awesome,
                                        label: 'Active AI',
                                        value: selectedAi,
                                        valueColor:
                                            const Color(0xFF0fadd5)),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ── Sign out button ───────────────────────────
                          _GlassCard(
                            padding: EdgeInsets.zero,
                            child: SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                onPressed: _confirmSignOut,
                                icon: const Icon(Icons.logout_rounded,
                                    color: Colors.redAccent, size: 18),
                                label: const Text(
                                  'Sign Out',
                                  style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 18),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable glass card ────────────────────────────────────────────────────────
class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _GlassCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1D3A).withOpacity(0.75),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF1E3A6E), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF38BDF8),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }
}

// ── Info row ─────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white38),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Thin divider ──────────────────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
        color: Colors.white.withOpacity(0.07), height: 16, thickness: 1);
  }
}
