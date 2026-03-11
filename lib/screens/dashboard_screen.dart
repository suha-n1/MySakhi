import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../theme/app_theme.dart';
import '../ble_service.dart';
import '../sos_service.dart';
import 'login_screen.dart';
import 'sos_alert_screen.dart';
import 'voice_codewords_screen.dart';
import 'contacts_screen.dart';
import 'helplines_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _profile;
  int _currentTab = 0;
  int _contactCount = 0;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  final BleService _bleService = BleService();

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _loadProfile();
    _loadContactCount();
    _listenForSos();
    _initBle();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _bleService.dispose();
    super.dispose();
  }

  void _initBle() {
    _bleService.onAlertReceived = () async {
      debugPrint('🚨 BLE ALERT received!');
      await SosService.sendSosToAll();
    };
    _bleService.addListener(() {
      if (mounted) setState(() {});
    });
    _bleService.startScan();
  }

  void _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (mounted) setState(() => _profile = doc.data());
  }

  void _loadContactCount() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('contacts')
        .get();
    if (mounted) setState(() => _contactCount = snap.docs.length);
  }

  void _listenForSos() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseDatabase.instance.ref('sos_events/$uid').onValue.listen((event) {
      if (!mounted) return;
      final data = event.snapshot.value as Map?;
      if (data != null && data['active'] == true) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => SosAlertScreen(
            latitude: (data['latitude'] ?? 0.0).toDouble(),
            longitude: (data['longitude'] ?? 0.0).toDouble(),
          ),
          fullscreenDialog: true,
        ));
      }
    });
  }

  Future<void> _logout() async {
    await _bleService.disconnect();
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _refreshAfterReturn() {
    _loadProfile();
    _loadContactCount();
  }

  void _navigate(int index) {
    setState(() => _currentTab = index);
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VoiceCodewordsScreen()),
      ).then((_) {
        setState(() => _currentTab = 0);
        _refreshAfterReturn();
      });
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ContactsScreen()),
      ).then((_) {
        setState(() => _currentTab = 0);
        _refreshAfterReturn();
      });
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HelplinesScreen()),
      ).then((_) => setState(() => _currentTab = 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?['name'] ?? '...';
    final codeword = _profile?['codeword'] ?? 'not set';
    final firstName = name.toString().split(' ').first;

    // BLE status values
    final bleConnected = _bleService.connected;
    final bleScanning = _bleService.scanning;
    final bleStatus = _bleService.status;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      body: Column(children: [
        // ── Pink header ──
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
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row
                  Row(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome back,',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 13)),
                        Text(firstName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            )),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _logout,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.settings_outlined,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 14),

                  // BLE Device status pill
                  GestureDetector(
                    onTap: !bleConnected && !bleScanning
                        ? () => _bleService.startScan()
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        // Status dot
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: bleConnected
                                ? const Color(0xFF4CAF8A)
                                : bleScanning
                                    ? Colors.orange
                                    : Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (bleConnected
                                        ? const Color(0xFF4CAF8A)
                                        : bleScanning
                                            ? Colors.orange
                                            : Colors.red)
                                    .withOpacity(0.6),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          bleConnected
                              ? 'BLE Device Connected · Listening'
                              : bleScanning
                                  ? 'Scanning for device...'
                                  : bleStatus,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                        if (!bleConnected && !bleScanning) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.refresh_rounded,
                              color: Colors.white70, size: 14),
                        ],
                      ]),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Codeword display
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(children: [
                      Expanded(
                        child: Text(
                          '"$codeword"',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const Icon(Icons.mic, color: Colors.white70, size: 20),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Body ──
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const SizedBox(height: 8),

              // SOS Button
              ScaleTransition(
                scale: _pulseAnim,
                child: GestureDetector(
                  onTap: () async {
                    await SosService.sendSosToAll();
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFF6B8A), Color(0xFFC0485F)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.rose.withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: AppColors.rose.withOpacity(0.2),
                          blurRadius: 80,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield, color: Colors.white, size: 52),
                        SizedBox(height: 4),
                        Text('SOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            )),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              const Text('Tap in emergency',
                  style: TextStyle(color: AppColors.muted, fontSize: 12)),

              const SizedBox(height: 32),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text('QUICK ACTIONS',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    )),
              ),
              const SizedBox(height: 12),

              _ActionCard(
                icon: Icons.mic_outlined,
                iconColor: AppColors.rose,
                title: 'Voice & Codewords',
                subtitle: 'Re-record or change codeword',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const VoiceCodewordsScreen()),
                ).then((_) => _refreshAfterReturn()),
              ),
              const SizedBox(height: 10),

              _ActionCard(
                icon: Icons.people_outline,
                iconColor: AppColors.rose,
                title: 'Emergency Contacts',
                subtitle:
                    '$_contactCount contact${_contactCount == 1 ? '' : 's'} saved',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ContactsScreen()),
                ).then((_) => _refreshAfterReturn()),
              ),
              const SizedBox(height: 10),

              _ActionCard(
                icon: Icons.phone_outlined,
                iconColor: const Color(0xFF4CAF8A),
                title: 'Emergency Helplines',
                subtitle: 'Police · Ambulance · Women helpline',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelplinesScreen()),
                ),
              ),

              const SizedBox(height: 10),

              // BLE reconnect card (shown when disconnected)
              if (!bleConnected)
                _ActionCard(
                  icon: Icons.bluetooth_searching_rounded,
                  iconColor: Colors.orange,
                  title: bleScanning
                      ? 'Scanning for device...'
                      : 'Connect Safety Band',
                  subtitle: bleScanning
                      ? 'Looking for WomenSafetyBand nearby'
                      : 'Tap to scan for your BLE device',
                  onTap: bleScanning ? () {} : () => _bleService.startScan(),
                ),
            ]),
          ),
        ),
      ]),

      // Bottom nav
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.rose.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: _navigate,
          selectedItemColor: AppColors.rose,
          unselectedItemColor: AppColors.muted,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.mic_outlined),
                activeIcon: Icon(Icons.mic_rounded),
                label: 'Voice'),
            BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people_rounded),
                label: 'Contacts'),
            BottomNavigationBarItem(
                icon: Icon(Icons.phone_outlined),
                activeIcon: Icon(Icons.phone_rounded),
                label: 'Helplines'),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.rose.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                      fontSize: 14,
                    )),
                Text(subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    )),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.muted, size: 22),
        ]),
      ),
    );
  }
}
