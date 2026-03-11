import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import 'codeword_screen.dart';

class VoiceCodewordsScreen extends StatefulWidget {
  const VoiceCodewordsScreen({super.key});
  @override
  State<VoiceCodewordsScreen> createState() => _VoiceCodewordsScreenState();
}

class _VoiceCodewordsScreenState extends State<VoiceCodewordsScreen> {
  String _currentCodeword = '';
  List<Map<String, dynamic>> _pastCodewords = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      final pastSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('past_codewords')
          .get();
      if (mounted) {
        setState(() {
          _currentCodeword = data?['codeword'] ?? 'not set';
          _pastCodewords = pastSnap.docs.map((d) => d.data()).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeCodeword() async {
    if (_currentCodeword.isNotEmpty && _currentCodeword != 'not set') {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('past_codewords')
          .add({
        'codeword': _currentCodeword,
        'changedAt': FieldValue.serverTimestamp(),
      });
    }
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const CodewordScreen(isOnboarding: false)),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      body: Column(children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE8637A), Color(0xFFFF8FA3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text('Voice & Codewords',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        )),
                  ]),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ACTIVE CODEWORD',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            )),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.mic, color: Colors.white, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            '"$_currentCodeword"',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        const Text(
                          'Your IoT device is listening for this word',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.rose))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Change codeword button
                      GestureDetector(
                        onTap: _changeCodeword,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE8637A), Color(0xFFFF5C7A)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.rose.withOpacity(0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Row(children: [
                            Icon(Icons.add_circle_outline,
                                color: Colors.white, size: 24),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Set New Codeword',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      )),
                                  Text('Record a new secret keyword',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      )),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 20),
                          ]),
                        ),
                      ),

                      const SizedBox(height: 28),

                      const Text('SUGGESTED CODEWORDS',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          )),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap any to use as your new codeword',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'Help me',
                          'Red alert',
                          'Call home',
                          'Flower code',
                          'Safe word',
                          'Bloom now',
                          'Emergency',
                          'Pizza time',
                          'Call Riya',
                        ]
                            .map((s) => GestureDetector(
                                  onTap: () async {
                                    final uid =
                                        FirebaseAuth.instance.currentUser!.uid;
                                    if (_currentCodeword != 'not set') {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(uid)
                                          .collection('past_codewords')
                                          .add({
                                        'codeword': _currentCodeword,
                                        'changedAt':
                                            FieldValue.serverTimestamp(),
                                      });
                                    }
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(uid)
                                        .update({'codeword': s});
                                    _loadData();
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Codeword changed to "$s"'),
                                        backgroundColor: AppColors.success,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: s == _currentCodeword
                                          ? AppColors.rose
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: s == _currentCodeword
                                            ? AppColors.rose
                                            : AppColors.border,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              AppColors.rose.withOpacity(0.06),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Text(s,
                                        style: TextStyle(
                                          color: s == _currentCodeword
                                              ? Colors.white
                                              : AppColors.dark,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        )),
                                  ),
                                ))
                            .toList(),
                      ),

                      const SizedBox(height: 28),

                      Row(children: [
                        const Text('PAST CODEWORDS',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            )),
                        const Spacer(),
                        Text('${_pastCodewords.length} total',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            )),
                      ]),
                      const SizedBox(height: 12),

                      if (_pastCodewords.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Center(
                            child: Text(
                              'No past codewords yet.\nThey\'ll appear here when you change your codeword.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      else
                        ..._pastCodewords.asMap().entries.map((e) {
                          final i = e.key;
                          final c = e.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: AppColors.rosePale,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text('${i + 1}',
                                      style: const TextStyle(
                                        color: AppColors.rose,
                                        fontWeight: FontWeight.w700,
                                      )),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('"${c['codeword']}"',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.dark,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 15,
                                        )),
                                    const Text('Previously used',
                                        style: TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 12,
                                        )),
                                  ],
                                ),
                              ),
                              const Icon(Icons.history,
                                  color: AppColors.muted, size: 18),
                            ]),
                          );
                        }),
                    ],
                  ),
                ),
        ),
      ]),
    );
  }
}
