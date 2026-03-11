import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart';

// ── Bubble data model ──
class _Bubble {
  double x, y, size, speed, opacity;
  _Bubble({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

// ── Animated bubbles painter ──
class _BubblePainter extends CustomPainter {
  final List<_Bubble> bubbles;
  _BubblePainter(this.bubbles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in bubbles) {
      final paint = Paint()
        ..color = const Color(0xFFE8637A).withOpacity(b.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(b.x * size.width, b.y * size.height),
        b.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BubblePainter old) => true;
}

// ── Bubble background widget ──
class _BubbleBackground extends StatefulWidget {
  const _BubbleBackground();
  @override
  State<_BubbleBackground> createState() => _BubbleBackgroundState();
}

class _BubbleBackgroundState extends State<_BubbleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final _rand = Random();
  late List<_Bubble> _bubbles;

  @override
  void initState() {
    super.initState();
    _bubbles = List.generate(
        12,
        (_) => _Bubble(
              x: _rand.nextDouble(),
              y: _rand.nextDouble(),
              size: 20 + _rand.nextDouble() * 50,
              speed: 0.0003 + _rand.nextDouble() * 0.0004,
              opacity: 0.05 + _rand.nextDouble() * 0.1,
            ));

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )
      ..addListener(() {
        setState(() {
          for (final b in _bubbles) {
            b.y -= b.speed;
            if (b.y < -0.1) {
              b.y = 1.1;
              b.x = _rand.nextDouble();
            }
          }
        });
      })
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BubblePainter(_bubbles),
      child: const SizedBox.expand(),
    );
  }
}

// ── Login Screen ──
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pink gradient base
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFDE8EC), Color(0xFFFDF6F7)],
              ),
            ),
          ),

          // Floating bubbles layer
          const _BubbleBackground(),

          // Login content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.rose,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined,
                        color: Colors.white, size: 38),
                  ),
                  const SizedBox(height: 20),
                  const Text('MySakhi',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      )),
                  const Text('welcome',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 15,
                      )),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Email address',
                      prefixIcon:
                          Icon(Icons.email_outlined, color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: AppColors.muted),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.muted,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('Log In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            )),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ",
                          style: TextStyle(color: AppColors.muted)),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignUpScreen()),
                        ),
                        child: const Text('Sign Up',
                            style: TextStyle(
                              color: AppColors.rose,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ],
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
