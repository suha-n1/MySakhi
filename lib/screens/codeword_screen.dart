import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import 'contacts_setup_screen.dart';

class CodewordScreen extends StatefulWidget {
  // isOnboarding = true → show Skip, go to Contacts after save
  // isOnboarding = false → no Skip, just save and go back
  final bool isOnboarding;
  const CodewordScreen({super.key, this.isOnboarding = true});

  @override
  State<CodewordScreen> createState() => _CodewordScreenState();
}

class _CodewordScreenState extends State<CodewordScreen>
    with SingleTickerProviderStateMixin {
  final _codewordCtrl = TextEditingController();
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  bool _loading = false;

  final List<String> _suggestions = [
    'Help me',
    'Red alert',
    'Call home',
    'Flower code',
    'Safe word',
    'Bloom now',
  ];

  final List<String> _recordingStatus = ['idle', 'idle', 'idle'];
  int _completedRecordings = 0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _codewordCtrl.dispose();
    super.dispose();
  }

  void _startRecording(int index) async {
    if (_recordingStatus[index] == 'recording') {
      setState(() {
        _recordingStatus[index] = 'done';
        _completedRecordings =
            _recordingStatus.where((s) => s == 'done').length;
      });
      return;
    }
    setState(() => _recordingStatus[index] = 'recording');
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    if (_recordingStatus[index] == 'recording') {
      setState(() {
        _recordingStatus[index] = 'done';
        _completedRecordings =
            _recordingStatus.where((s) => s == 'done').length;
      });
    }
  }

  Future<void> _save() async {
    if (_codewordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please enter a codeword'),
        backgroundColor: AppColors.rose,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    if (_completedRecordings < 3) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please complete all 3 recordings'),
        backgroundColor: AppColors.rose,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }

    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'codeword': _codewordCtrl.text.trim()});

      if (!mounted) return;

      if (widget.isOnboarding) {
        // During setup → go to contacts
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ContactsSetupScreen()),
        );
      } else {
        // From settings → just go back with success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Codeword updated successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        Navigator.pop(context);
      }
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Header row
              Row(children: [
                // Back button (always shown)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.rosePale,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.roseLight),
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.rose, size: 20),
                  ),
                ),

                // Step indicator (only during onboarding)
                if (widget.isOnboarding) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.rosePale,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.roseLight),
                    ),
                    child: const Row(children: [
                      Icon(Icons.circle_outlined,
                          size: 8, color: AppColors.muted),
                      SizedBox(width: 4),
                      Icon(Icons.circle, size: 8, color: AppColors.rose),
                      SizedBox(width: 4),
                      Icon(Icons.circle_outlined,
                          size: 8, color: AppColors.muted),
                    ]),
                  ),
                ],
                const Spacer(),

                // Title when NOT onboarding
                if (!widget.isOnboarding)
                  const Text('Update Codeword',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                        fontSize: 16,
                      )),
              ]),

              const SizedBox(height: 24),

              // Mic icon with pulse
              Center(
                child: ScaleTransition(
                  scale: _pulseAnim,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE8637A), Color(0xFFFF5C7A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.rose.withOpacity(0.4),
                          blurRadius: 24,
                          spreadRadius: 4,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 42),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  widget.isOnboarding
                      ? 'Set Your Codeword'
                      : 'Record New Codeword',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
              ),
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Choose a secret keyword and record it 3 times.\nYour IoT device will listen for this word.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Text('Enter your codeword',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                    fontSize: 14,
                  )),
              const SizedBox(height: 10),
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
                child: TextFormField(
                  controller: _codewordCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Help me',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text('Suggested codewords:',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  )),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestions
                    .map((s) => GestureDetector(
                          onTap: () => setState(() => _codewordCtrl.text = s),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _codewordCtrl.text == s
                                  ? AppColors.rose
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _codewordCtrl.text == s
                                    ? AppColors.rose
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(s,
                                style: TextStyle(
                                  color: _codewordCtrl.text == s
                                      ? Colors.white
                                      : AppColors.dark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                )),
                          ),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 28),

              Text(
                'Record your voice saying '
                '"${_codewordCtrl.text.isEmpty ? '...' : _codewordCtrl.text}" three times:',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),

              ...List.generate(
                  3,
                  (i) => _RecordingSlot(
                        index: i + 1,
                        status: _recordingStatus[i],
                        onTap: () => _startRecording(i),
                      )),

              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '$_completedRecordings/3',
                    style: TextStyle(
                      color: _completedRecordings == 3
                          ? AppColors.success
                          : AppColors.muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Save button
              GestureDetector(
                onTap: _loading ? null : _save,
                child: Container(
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _completedRecordings == 3
                          ? [const Color(0xFFE8637A), const Color(0xFFFF5C7A)]
                          : [AppColors.roseLight, AppColors.roseLight],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: _completedRecordings == 3
                        ? [
                            BoxShadow(
                              color: AppColors.rose.withOpacity(0.4),
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
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.isOnboarding
                                    ? 'Save & Continue'
                                    : 'Save Codeword',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 20),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordingSlot extends StatelessWidget {
  final int index;
  final String status;
  final VoidCallback onTap;

  const _RecordingSlot({
    required this.index,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRecording = status == 'recording';
    final isDone = status == 'done';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDone
            ? AppColors.success.withOpacity(0.06)
            : isRecording
                ? AppColors.rose.withOpacity(0.06)
                : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone
              ? AppColors.success.withOpacity(0.4)
              : isRecording
                  ? AppColors.rose.withOpacity(0.4)
                  : AppColors.border,
        ),
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.success.withOpacity(0.12)
                : isRecording
                    ? AppColors.rose.withOpacity(0.12)
                    : AppColors.rosePale,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDone
                ? Icons.check_rounded
                : isRecording
                    ? Icons.stop_rounded
                    : Icons.mic_none_rounded,
            color: isDone
                ? AppColors.success
                : isRecording
                    ? AppColors.rose
                    : AppColors.muted,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recording $index',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                    fontSize: 14,
                  )),
              Text(
                isDone
                    ? '✓ Recorded successfully'
                    : isRecording
                        ? 'Recording... tap to stop'
                        : 'Tap to record',
                style: TextStyle(
                  color: isDone
                      ? AppColors.success
                      : isRecording
                          ? AppColors.rose
                          : AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: isDone ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isDone ? AppColors.success.withOpacity(0.1) : AppColors.rose,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isDone
                  ? 'Done ✓'
                  : isRecording
                      ? 'Stop'
                      : 'Record',
              style: TextStyle(
                color: isDone ? AppColors.success : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
