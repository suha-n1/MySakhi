import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class HelplinesScreen extends StatefulWidget {
  const HelplinesScreen({super.key});
  @override
  State<HelplinesScreen> createState() => _HelplinesScreenState();
}

class _HelplineItem {
  final String name, number, desc, category;
  final IconData icon;
  final Color color;
  final bool isNgo;
  const _HelplineItem({
    required this.name,
    required this.number,
    required this.desc,
    required this.category,
    required this.icon,
    required this.color,
    this.isNgo = false,
  });
}

class _HelplinesScreenState extends State<HelplinesScreen> {
  final _cityCtrl = TextEditingController();
  String _selectedCity = '';
  int _selectedCategory = 0;

  final List<String> _categories = [
    'All',
    'Women',
    'Police',
    'Medical',
    'Mental Health',
    'Children'
  ];

  final List<_HelplineItem> _helplines = const [
    _HelplineItem(
      name: 'Women Helpline',
      number: '1091',
      desc: '24/7 emergency helpline for women',
      category: 'Women',
      icon: Icons.woman_rounded,
      color: Color(0xFFE8637A),
    ),
    _HelplineItem(
      name: 'Police',
      number: '100',
      desc: 'Emergency police assistance',
      category: 'Police',
      icon: Icons.local_police_outlined,
      color: Color(0xFF3D5AF1),
    ),
    _HelplineItem(
      name: 'Ambulance',
      number: '108',
      desc: 'Emergency medical services',
      category: 'Medical',
      icon: Icons.medical_services_outlined,
      color: Color(0xFF4CAF8A),
    ),
    _HelplineItem(
      name: 'National Emergency',
      number: '112',
      desc: 'All-in-one emergency number',
      category: 'Police',
      icon: Icons.emergency_rounded,
      color: Color(0xFFFF6B35),
    ),
    _HelplineItem(
      name: 'iCall (Mental Health)',
      number: '9152987821',
      desc: 'Free psychological counselling',
      category: 'Mental Health',
      icon: Icons.psychology_outlined,
      color: Color(0xFF9C27B0),
    ),
    _HelplineItem(
      name: 'Vandrevala Foundation',
      number: '18602662345',
      desc: '24/7 mental health crisis helpline',
      category: 'Mental Health',
      icon: Icons.favorite_outline,
      color: Color(0xFF9C27B0),
    ),
    _HelplineItem(
      name: 'Childline',
      number: '1098',
      desc: 'Child helpline — abuse & trafficking',
      category: 'Children',
      icon: Icons.child_care_outlined,
      color: Color(0xFFFF9800),
    ),
    _HelplineItem(
      name: 'Domestic Violence (NCW)',
      number: '7827170170',
      desc: 'National Commission for Women',
      category: 'Women',
      icon: Icons.shield_outlined,
      color: Color(0xFFE8637A),
    ),
    _HelplineItem(
      name: 'Fire Department',
      number: '101',
      desc: 'Fire emergency services',
      category: 'Police',
      icon: Icons.local_fire_department_outlined,
      color: Color(0xFFFF6B35),
    ),
    _HelplineItem(
      name: 'Anti-Poison',
      number: '1800116117',
      desc: 'Poison control helpline',
      category: 'Medical',
      icon: Icons.warning_amber_outlined,
      color: Color(0xFF4CAF8A),
    ),
  ];

  final Map<String, List<_HelplineItem>> _ngosByCity = const {
    'delhi': [
      _HelplineItem(
          name: 'Shakti Shalini',
          number: '01124373737',
          desc: 'Women in distress, domestic violence',
          category: 'Women',
          icon: Icons.volunteer_activism_outlined,
          color: Color(0xFF4CAF8A),
          isNgo: true),
      _HelplineItem(
          name: 'Jagori',
          number: '01126692700',
          desc: 'Women safety & rights',
          category: 'Women',
          icon: Icons.volunteer_activism_outlined,
          color: Color(0xFF4CAF8A),
          isNgo: true),
      _HelplineItem(
          name: 'Sanjivini',
          number: '01124311918',
          desc: 'Mental health counselling',
          category: 'Mental Health',
          icon: Icons.volunteer_activism_outlined,
          color: Color(0xFF4CAF8A),
          isNgo: true),
      _HelplineItem(
          name: 'Prayas',
          number: '01123970346',
          desc: 'Children in need of care',
          category: 'Children',
          icon: Icons.volunteer_activism_outlined,
          color: Color(0xFF4CAF8A),
          isNgo: true),
    ],
    'mumbai': [
      _HelplineItem(
          name: 'iCall TISS',
          number: '9152987821',
          desc: 'Free psychological counselling',
          category: 'Mental Health',
          icon: Icons.volunteer_activism_outlined,
          color: Color(0xFF4CAF8A),
          isNgo: true),
      _HelplineItem(
          name: 'Majlis',
          number: '02223823088',
          desc: 'Legal aid for women',
          category: 'Women',
          icon: Icons.volunteer_activism_outlined,
          color: Color(0xFF4CAF8A),
          isNgo: true),
      _HelplineItem(
          name: 'Arpan',
          number: '02225521054',
          desc: 'Child sexual abuse prevention',
          category: 'Children',
          icon: Icons.volunteer_activism_outlined,
          color: Color(0xFF4CAF8A),
          isNgo: true),
    ],
    'bangalore': [
      _HelplineItem(
          name: 'Parihar',
          number: '08022943225',
          desc: 'Women in domestic violence crisis',
          category: 'Women',
          icon: Icons.volunteer_activism_outlined,
          color: Color(0xFF4CAF8A),
          isNgo: true),
      _HelplineItem(
          name: 'Enfold',
          number: '08025273466',
          desc: 'Child protection & safety',
          category: 'Children',
          icon: Icons.volunteer_activism_outlined,
          color: Color(0xFF4CAF8A),
          isNgo: true),
      _HelplineItem(
          name: 'Vandana',
          number: '08025281929',
          desc: 'Support for women in crisis',
          category: 'Women',
          icon: Icons.volunteer_activism_outlined,
          color: Color(0xFF4CAF8A),
          isNgo: true),
    ],
    'chennai': [
      _HelplineItem(
          name: 'Snehi Tamil Nadu',
          number: '04424640050',
          desc: 'Emotional support & suicide prevention',
          category: 'Mental Health',
          icon: Icons.volunteer_activism_outlined,
          color: Color(0xFF4CAF8A),
          isNgo: true),
      _HelplineItem(
          name: 'BSSO',
          number: '04426208583',
          desc: 'Women welfare organization',
          category: 'Women',
          icon: Icons.volunteer_activism_outlined,
          color: Color(0xFF4CAF8A),
          isNgo: true),
    ],
    'hyderabad': [
      _HelplineItem(
          name: 'Prajwala',
          number: '04023392115',
          desc: 'Anti-trafficking, women rescue',
          category: 'Women',
          icon: Icons.volunteer_activism_outlined,
          color: Color(0xFF4CAF8A),
          isNgo: true),
      _HelplineItem(
          name: 'Sahayak',
          number: '04027617117',
          desc: 'Counselling & crisis support',
          category: 'Mental Health',
          icon: Icons.volunteer_activism_outlined,
          color: Color(0xFF4CAF8A),
          isNgo: true),
    ],
    'kolkata': [
      _HelplineItem(
          name: 'Swayam',
          number: '03324860041',
          desc: 'Women empowerment & crisis support',
          category: 'Women',
          icon: Icons.volunteer_activism_outlined,
          color: Color(0xFF4CAF8A),
          isNgo: true),
      _HelplineItem(
          name: 'Sanlaap',
          number: '03325551264',
          desc: 'Anti-trafficking, child protection',
          category: 'Children',
          icon: Icons.volunteer_activism_outlined,
          color: Color(0xFF4CAF8A),
          isNgo: true),
    ],
    'pune': [
      _HelplineItem(
          name: 'iCall Pune',
          number: '9152987821',
          desc: 'Psychological first aid',
          category: 'Mental Health',
          icon: Icons.volunteer_activism_outlined,
          color: Color(0xFF4CAF8A),
          isNgo: true),
      _HelplineItem(
          name: 'Prerana',
          number: '02223027751',
          desc: 'Anti-trafficking intervention',
          category: 'Children',
          icon: Icons.volunteer_activism_outlined,
          color: Color(0xFF4CAF8A),
          isNgo: true),
    ],
  };

  Future<void> _call(String number) async {
    final clean = number.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Call $number'),
        backgroundColor: AppColors.rose,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  List<_HelplineItem> get _filteredHelplines {
    if (_selectedCategory == 0) return _helplines;
    return _helplines
        .where((h) => h.category == _categories[_selectedCategory])
        .toList();
  }

  List<_HelplineItem> get _filteredNgos {
    final city = _selectedCity.toLowerCase().trim();
    if (city.isEmpty) return [];
    for (final key in _ngosByCity.keys) {
      if (city.contains(key) || key.contains(city)) {
        return _ngosByCity[key]!;
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final ngos = _filteredNgos;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      body: Column(children: [
        // Header
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF8A), Color(0xFF66BB6A)],
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
                    const Text('Emergency Helplines',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        )),
                  ]),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Row(children: [
                      Icon(Icons.info_outline, color: Colors.white70, size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Tap the call button on any card.\nAll national helplines are free & 24/7.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category chips
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => setState(() => _selectedCategory = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedCategory == i
                              ? const Color(0xFF4CAF8A)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedCategory == i
                                ? const Color(0xFF4CAF8A)
                                : AppColors.border,
                          ),
                          boxShadow: _selectedCategory == i
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF4CAF8A)
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Text(_categories[i],
                            style: TextStyle(
                              color: _selectedCategory == i
                                  ? Colors.white
                                  : AppColors.dark,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            )),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text('NATIONAL HELPLINES',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    )),
                const SizedBox(height: 12),

                ..._filteredHelplines.map((h) => _HelplineCard(
                      item: h,
                      onCall: () => _call(h.number),
                    )),

                const SizedBox(height: 28),

                const Text('NGOS NEAR YOU',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    )),
                const SizedBox(height: 4),
                const Text(
                  'Enter your city to find local support',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 12),

                // City search box
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.rose.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _cityCtrl,
                    onChanged: (v) => setState(() => _selectedCity = v),
                    decoration: InputDecoration(
                      hintText: 'e.g. Delhi, Mumbai, Bangalore...',
                      prefixIcon: const Icon(Icons.location_city_outlined,
                          color: AppColors.muted),
                      suffixIcon: _cityCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: AppColors.muted, size: 18),
                              onPressed: () {
                                _cityCtrl.clear();
                                setState(() => _selectedCity = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // NGO results
                if (_selectedCity.isEmpty)
                  _EmptyState(
                    icon: Icons.location_city_outlined,
                    title: 'Enter your city above',
                    subtitle: 'We\'ll show NGOs available in your area',
                  )
                else if (ngos.isEmpty)
                  _EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No NGOs found for "$_selectedCity"',
                    subtitle:
                        'Try: Delhi, Mumbai, Bangalore,\nChennai, Hyderabad, Kolkata, Pune',
                  )
                else ...[
                  Text(
                    '${ngos.length} NGOs found in $_selectedCity',
                    style: const TextStyle(
                      color: Color(0xFF4CAF8A),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...ngos.map((n) => _HelplineCard(
                        item: n,
                        onCall: () => _call(n.number),
                      )),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        Icon(icon, size: 40, color: AppColors.muted),
        const SizedBox(height: 10),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.dark,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            )),
        const SizedBox(height: 4),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, fontSize: 12)),
      ]),
    );
  }
}

class _HelplineCard extends StatelessWidget {
  final _HelplineItem item;
  final VoidCallback onCall;

  const _HelplineCard({
    required this.item,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Flexible(
                    child: Text(item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                          fontSize: 14,
                        )),
                  ),
                  if (item.isNgo) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF8A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('NGO',
                          style: TextStyle(
                            color: Color(0xFF4CAF8A),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                  ],
                ]),
                Text(item.desc,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    )),
                const SizedBox(height: 2),
                Text(item.number,
                    style: TextStyle(
                      color: item.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    )),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCall,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: item.color.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.phone_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ]),
      ),
    );
  }
}
