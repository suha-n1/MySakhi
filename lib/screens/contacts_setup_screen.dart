import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

class ContactsSetupScreen extends StatefulWidget {
  const ContactsSetupScreen({super.key});
  @override
  State<ContactsSetupScreen> createState() => _ContactsSetupScreenState();
}

class _ContactsSetupScreenState extends State<ContactsSetupScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final List<Map<String, String>> _contacts = [];
  bool _loading = false;

  void _addContact() {
    if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter both name and phone'),
          backgroundColor: AppColors.rose,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() {
      _contacts.add({
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
      });
      _nameCtrl.clear();
      _phoneCtrl.clear();
    });
  }

  Future<void> _finish() async {
    if (_contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add at least one emergency contact'),
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
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

      for (final c in _contacts) {
        await userRef.collection('contacts').add({
          'name': c['name'],
          'phone': c['phone'],
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
      await userRef.update({'setupComplete': true});

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (_) => false,
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
      backgroundColor: const Color(0xFFFFF5F7),
      body: Stack(
        children: [
          // Top pink arc
          Positioned(
            top: -60,
            left: -40,
            right: -40,
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8637A), Color(0xFFFF8FA3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.rose.withOpacity(0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(children: [
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
                        Icon(Icons.circle_outlined,
                            size: 8, color: Colors.white70),
                        SizedBox(width: 4),
                        Icon(Icons.circle_outlined,
                            size: 8, color: Colors.white70),
                        SizedBox(width: 4),
                        Icon(Icons.circle, size: 8, color: Colors.white),
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
                      child: const Icon(Icons.people_outline,
                          color: Colors.white, size: 20),
                    ),
                  ]),
                ),

                const SizedBox(height: 12),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Who keeps',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 18)),
                        Text('you safe? 🤍',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            )),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Main card
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.rose.withOpacity(0.1),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Input area
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(children: [
                            // Name field
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.rosePale,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color:
                                        AppColors.roseLight.withOpacity(0.5)),
                              ),
                              child: TextFormField(
                                controller: _nameCtrl,
                                decoration: const InputDecoration(
                                  hintText: 'Contact name (e.g. Mom)',
                                  prefixIcon: Icon(Icons.person_outline,
                                      color: AppColors.rose),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Phone + Add button row
                            Row(children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.rosePale,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: AppColors.roseLight
                                            .withOpacity(0.5)),
                                  ),
                                  child: TextFormField(
                                    controller: _phoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                      hintText: '+91 phone number',
                                      prefixIcon: Icon(Icons.phone_outlined,
                                          color: AppColors.rose),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: _addContact,
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFE8637A),
                                        Color(0xFFFF5C7A)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.rose.withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.add_rounded,
                                      color: Colors.white, size: 28),
                                ),
                              ),
                            ]),
                          ]),
                        ),

                        // Divider
                        Container(
                          height: 1,
                          color: AppColors.border,
                        ),

                        // Contacts list
                        Expanded(
                          child: _contacts.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.people_outline,
                                          size: 48,
                                          color:
                                              AppColors.muted.withOpacity(0.4)),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'No contacts yet\nAdd someone who can help you',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _contacts.length,
                                  itemBuilder: (_, i) {
                                    final c = _contacts[i];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: AppColors.rosePale,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: AppColors.roseLight
                                                .withOpacity(0.5)),
                                      ),
                                      child: Row(children: [
                                        Container(
                                          width: 42,
                                          height: 42,
                                          decoration: const BoxDecoration(
                                            color: AppColors.rose,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              c['name']![0].toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
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
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.dark,
                                                  )),
                                              Text(c['phone']!,
                                                  style: const TextStyle(
                                                    color: AppColors.muted,
                                                    fontSize: 12,
                                                  )),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              color: AppColors.muted),
                                          onPressed: () => setState(
                                              () => _contacts.removeAt(i)),
                                        ),
                                      ]),
                                    );
                                  },
                                ),
                        ),

                        // Finish button
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: GestureDetector(
                            onTap: _loading ? null : _finish,
                            child: Container(
                              height: 58,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _contacts.isNotEmpty
                                      ? [
                                          const Color(0xFFE8637A),
                                          const Color(0xFFFF5C7A)
                                        ]
                                      : [
                                          AppColors.roseLight,
                                          AppColors.roseLight
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: _contacts.isNotEmpty
                                    ? [
                                        BoxShadow(
                                          color:
                                              AppColors.rose.withOpacity(0.4),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: _loading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.check_circle_outline,
                                              color: Colors.white, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            _contacts.isEmpty
                                                ? 'Add a contact first'
                                                : 'Finish Setup →',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
