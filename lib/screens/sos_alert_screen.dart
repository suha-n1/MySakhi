import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../theme/app_theme.dart';

class SosAlertScreen extends StatefulWidget {
  final double latitude, longitude;
  const SosAlertScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });
  @override
  State<SosAlertScreen> createState() => _SosAlertScreenState();
}

class _SosAlertScreenState extends State<SosAlertScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  bool _notified = false;
  List<Map<String, String>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _loadContactsAndNotify();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadContactsAndNotify() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('contacts')
        .get();

    final contacts = snap.docs
        .map((d) => {
              'name': d.data()['name']?.toString() ?? '',
              'phone': d.data()['phone']?.toString() ?? '',
            })
        .toList();

    if (mounted) {
      setState(() {
        _contacts = contacts;
        _notified = true;
      });
    }
  }

  Future<void> _dismiss() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseDatabase.instance
          .ref('sos_events/$uid')
          .update({'active': false});
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  String get _mapsLink =>
      'https://maps.google.com/?q=${widget.latitude},${widget.longitude}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC0485F),
      body: Stack(
        children: [
          // Pulsing background circles
          Center(
            child: ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
          ),
          Center(
            child: ScaleTransition(
              scale: ReverseAnimation(_pulseAnim),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Emergency icon
                  ScaleTransition(
                    scale: _pulseAnim,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3), width: 2),
                      ),
                      child: const Icon(
                        Icons.emergency_rounded,
                        color: Colors.white,
                        size: 52,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'SOS ALERT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _notified
                        ? '✓ ${_contacts.length} contact${_contacts.length == 1 ? '' : 's'} being notified'
                        : 'Notifying your contacts...',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Contacts being notified
                  if (_contacts.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ALERTING',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              )),
                          const SizedBox(height: 10),
                          ..._contacts.map((c) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        c['name']![0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
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
                                        Text(c['name']!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            )),
                                        Text(c['phone']!,
                                            style: const TextStyle(
                                              color: Colors.white60,
                                              fontSize: 11,
                                            )),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.check_circle,
                                      color: Color(0xFF4CAF8A), size: 18),
                                ]),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Location card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Column(children: [
                      const Row(children: [
                        Icon(Icons.location_pin,
                            color: Colors.white70, size: 16),
                        SizedBox(width: 6),
                        Text('GPS LOCATION',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            )),
                      ]),
                      const SizedBox(height: 10),
                      Text(
                        widget.latitude == 0 && widget.longitude == 0
                            ? 'Location not available\n(manual trigger)'
                            : '${widget.latitude.toStringAsFixed(6)}\n${widget.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.latitude != 0) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.map_outlined,
                                    color: Colors.white, size: 16),
                                SizedBox(width: 8),
                                Text('View on Google Maps',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ]),
                  ),

                  const Spacer(),

                  // I am safe button
                  GestureDetector(
                    onTap: _dismiss,
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: Color(0xFFC0485F), size: 22),
                            SizedBox(width: 10),
                            Text(
                              'I am safe — dismiss alert',
                              style: TextStyle(
                                color: Color(0xFFC0485F),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Alert will automatically dismiss\nwhen marked safe',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
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
