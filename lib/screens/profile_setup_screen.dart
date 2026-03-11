import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import 'codeword_screen.dart';

// ── Animated mesh background ──
class _MeshPainter extends CustomPainter {
  final double t;
  _MeshPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final blobs = [
      _Blob(0.2, 0.15, 180, const Color(0xFFE8637A), 0.18, 0.0),
      _Blob(0.8, 0.1, 220, const Color(0xFFFF8FA3), 0.14, 0.5),
      _Blob(0.1, 0.7, 160, const Color(0xFFFFB3C1), 0.12, 1.0),
      _Blob(0.85, 0.75, 200, const Color(0xFFE8637A), 0.1, 1.5),
      _Blob(0.5, 0.5, 250, const Color(0xFFFF6B8A), 0.08, 2.0),
    ];
    for (final b in blobs) {
      final dx = sin(t * 2 * pi + b.phase) * 30;
      final dy = cos(t * 2 * pi * 0.7 + b.phase) * 25;
      final paint = Paint()
        ..color = b.color.withOpacity(b.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
      canvas.drawCircle(
        Offset(b.x * size.width + dx, b.y * size.height + dy),
        b.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_MeshPainter old) => old.t != t;
}

class _Blob {
  final double x, y, radius, opacity, phase;
  final Color color;
  const _Blob(
      this.x, this.y, this.radius, this.color, this.opacity, this.phase);
}

class _AnimatedMesh extends StatefulWidget {
  const _AnimatedMesh();
  @override
  State<_AnimatedMesh> createState() => _AnimatedMeshState();
}

class _AnimatedMeshState extends State<_AnimatedMesh>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _MeshPainter(_ctrl.value),
        child: const SizedBox.expand(),
      ),
    );
  }
}

// ── Floating label input ──
class _GlassInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;

  const _GlassInput({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8637A).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: AppColors.dark,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.muted.withOpacity(0.7)),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE8637A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.rose, size: 18),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }
}

// ── Main Screen ──
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  bool _locationGranted = false;
  bool _loading = false;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeIn);
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_nameCtrl.text.isEmpty || _ageCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all fields'),
          backgroundColor: AppColors.rose,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (!_locationGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enable location to continue'),
          backgroundColor: AppColors.rose,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final email = FirebaseAuth.instance.currentUser!.email!;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameCtrl.text.trim(),
        'email': email,
        'age': int.parse(_ageCtrl.text.trim()),
        'setupComplete': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CodewordScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // White base
          Container(color: const Color(0xFFFFF5F7)),

          // Animated mesh blobs
          const _AnimatedMesh(),

          // Frosted top arc decoration
          Positioned(
            top: -60,
            left: -40,
            right: -40,
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE8637A), Color(0xFFFF8FA3)],
                ),
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8637A).withOpacity(0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
                  child: Row(
                    children: [
                      // Step indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.4)),
                        ),
                        child: const Row(children: [
                          Icon(Icons.circle, size: 8, color: Colors.white),
                          SizedBox(width: 4),
                          Icon(Icons.circle_outlined,
                              size: 8, color: Colors.white70),
                          SizedBox(width: 4),
                          Icon(Icons.circle_outlined,
                              size: 8, color: Colors.white70),
                        ]),
                      ),
                      const Spacer(),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield_outlined,
                            color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Title in header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tell us about',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          'yourself 🌸',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Form card
                Expanded(
                  child: SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE8637A).withOpacity(0.12),
                              blurRadius: 40,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name input
                              _GlassInput(
                                controller: _nameCtrl,
                                hint: 'Full Name',
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 14),

                              // Age input
                              _GlassInput(
                                controller: _ageCtrl,
                                hint: 'Age',
                                icon: Icons.cake_outlined,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 14),

                              // Location card
                              GestureDetector(
                                onTap: () => setState(
                                    () => _locationGranted = !_locationGranted),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _locationGranted
                                        ? const Color(0xFF4CAF8A)
                                            .withOpacity(0.08)
                                        : Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _locationGranted
                                          ? const Color(0xFF4CAF8A)
                                          : AppColors.border,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFE8637A)
                                            .withOpacity(0.06),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Row(children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: _locationGranted
                                            ? const Color(0xFF4CAF8A)
                                                .withOpacity(0.15)
                                            : AppColors.rose.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _locationGranted
                                            ? Icons.location_on
                                            : Icons.location_on_outlined,
                                        color: _locationGranted
                                            ? const Color(0xFF4CAF8A)
                                            : AppColors.rose,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Location Access',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.dark,
                                                  fontSize: 14)),
                                          Text(
                                            _locationGranted
                                                ? 'Enabled — you\'re protected!'
                                                : 'Tap to enable — required for SOS',
                                            style: TextStyle(
                                              color: _locationGranted
                                                  ? const Color(0xFF4CAF8A)
                                                  : AppColors.muted,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      width: 48,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: _locationGranted
                                            ? const Color(0xFF4CAF8A)
                                            : AppColors.border,
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: AnimatedAlign(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        alignment: _locationGranted
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Container(
                                          margin: const EdgeInsets.all(3),
                                          width: 20,
                                          height: 20,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Continue button
                              GestureDetector(
                                onTap: _loading ? null : _continue,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 58,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _loading
                                          ? [
                                              AppColors.roseLight,
                                              AppColors.roseLight
                                            ]
                                          : [
                                              const Color(0xFFE8637A),
                                              const Color(0xFFFF5C7A),
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFE8637A)
                                            .withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: _loading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Continue',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(Icons.arrow_forward_rounded,
                                                  color: Colors.white,
                                                  size: 20),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
