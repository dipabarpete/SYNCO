import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../services/stress_wellbeing_local_store.dart';

/// Private, prompt-based journaling tool.
///
/// Entries are saved on this device only, scoped to the signed-in user —
/// never uploaded, never shown publicly, never sent to external services.
class JournalToolScreen extends StatefulWidget {
  const JournalToolScreen({super.key});

  @override
  State<JournalToolScreen> createState() => _JournalToolScreenState();
}

const _lavender = Color(0xFF7B4397);
const _lavenderLight = Color(0xFFF4EFFB);

const _prompts = [
  'How are you feeling today?',
  'What is taking up most of your mental space?',
  'What helped you feel a little better today?',
  'Anything else on your mind — no rules here',
];

class _JournalToolScreenState extends State<JournalToolScreen> {
  final TextEditingController _controller = TextEditingController();
  int _selectedPrompt = 0;
  List<StressJournalEntry> _entries = const [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final entries = await StressWellbeingLocalStore.loadJournals();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loaded = true;
    });
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Write a few words first \u2014 anything counts.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    await StressWellbeingLocalStore.saveJournal(
      StressJournalEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        prompt: _prompts[_selectedPrompt],
        text: text,
      ),
    );
    _controller.clear();
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved privately to this device.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _lavender,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Journaling',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Privacy note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _lavenderLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFD8B4F8).withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                    color: _lavender,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your journal lives on this device only, tied to your account. '
                      'No one else can see it — and it\u2019s never sent anywhere.',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        height: 1.45,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Prompt selector
            Text(
              'Choose a prompt',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < _prompts.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPrompt = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedPrompt == i
                          ? _lavenderLight
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _selectedPrompt == i
                            ? _lavender
                            : AppColors.borderGrey,
                        width: _selectedPrompt == i ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedPrompt == i
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          size: 18,
                          color: _selectedPrompt == i
                              ? _lavender
                              : AppColors.textLight,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _prompts[i],
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: _selectedPrompt == i
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 6),

            // Writing area
            TextField(
              controller: _controller,
              maxLines: 6,
              minLines: 4,
              decoration: InputDecoration(
                hintText: 'Write whatever comes to mind \u2014 it\u2019s just for you\u2026',
                hintStyle: GoogleFonts.inter(
                  color: AppColors.textLight,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.borderGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.borderGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _lavender, width: 1.6),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _lavender,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              child: Text(
                'Save entry',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // My entries
            Row(
              children: [
                const Icon(Icons.edit_note_rounded, size: 20, color: _lavender),
                const SizedBox(width: 8),
                Text(
                  'My entries',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (!_loaded)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _lavender,
                    ),
                  ),
                ),
              )
            else if (_entries.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.borderGrey.withValues(alpha: 0.7),
                  ),
                ),
                child: Text(
                  'No entries yet. Your first private note can be as short as one sentence.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    height: 1.5,
                    color: AppColors.textMedium,
                  ),
                ),
              )
            else
              for (final entry in _entries)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.borderGrey.withValues(alpha: 0.7),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 13,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              entry.prompt,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _lavender,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.text,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        StressWellbeingLocalStore.friendlyDate(entry.date),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}