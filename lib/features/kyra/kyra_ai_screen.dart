import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hersync/models/cycle_data.dart';
import '../../core/theme/app_colors.dart';
import '../../models/kyra_message.dart';
import '../../providers/app_providers.dart';

class KyraAiScreen extends ConsumerStatefulWidget {
  const KyraAiScreen({super.key});

  @override
  ConsumerState<KyraAiScreen> createState() => _KyraAiScreenState();
}

class _KyraAiScreenState extends ConsumerState<KyraAiScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isListeningVoice = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(kyraMessagesProvider);
    final health = ref.watch(healthMetricsProvider);
    final cycle = ref.watch(cycleDataProvider);

    _scrollToBottom();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kyra AI Companion',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Connected to Cycle & Health Logs',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.document_scanner_outlined,
              color: AppColors.softPurple,
            ),
            onPressed: () => _showLabReportScanModal(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Real-time Context Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.softLavender.withValues(alpha: 0.4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Phase: ${cycle.currentPhase.displayName} (Day ${cycle.currentDayOfCycle})',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.softPurple,
                  ),
                ),
                Text(
                  'Health Score: ${health.calculatedScore}/100',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.softPurple,
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (ctx, i) {
                final msg = messages[i];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // Suggested Quick Prompts Row
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildPromptChip('Analyze my lab report'),
                _buildPromptChip('PCOS diet recommendations'),
                _buildPromptChip('Why am I tired today?'),
                _buildPromptChip('Cycle Summary & Insights'),
              ],
            ),
          ),
          const SizedBox(height: 6),


          // Bottom Input Bar with Voice Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Voice Input Button Simulation
                IconButton(
                  icon: Icon(
                    _isListeningVoice
                        ? Icons.mic_rounded
                        : Icons.mic_none_rounded,
                    color: _isListeningVoice
                        ? Colors.redAccent
                        : AppColors.softPurple,
                  ),
                  onPressed: () {
                    setState(() => _isListeningVoice = !_isListeningVoice);
                    if (_isListeningVoice) {
                      _textController.text =
                          'Kyra, what food should I eat for PCOS energy?';
                    }
                  },
                ),

                // Text Field Input
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText:
                          'Ask Kyra about your health, cycle, or lab reports...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textLight,
                      ),
                      filled: true,
                      fillColor: AppColors.lightGrey,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (text) => _sendMessage(text),
                  ),
                ),
                const SizedBox(width: 8),

                // Send Button
                GestureDetector(
                  onTap: () => _sendMessage(_textController.text),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(KyraMessage msg) {
    final isKyra = msg.sender == KyraSender.kyra;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isKyra
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (isKyra) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.softPurple,
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isKyra
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isKyra
                        ? Theme.of(context).cardColor
                        : AppColors.softPurple,
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomLeft: isKyra
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                      bottomRight: !isKyra
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: isKyra
                        ? Border.all(
                            color: AppColors.borderGrey.withValues(alpha: 0.4),
                          )
                        : null,
                  ),
                  child: Text(
                    msg.text,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isKyra ? AppColors.textDark : Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),

                // Optional Lab Report Analysis Card
                if (msg.labReportInsight != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.softLavender.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.softPurple.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      msg.labReportInsight!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],

                // Optional Food Suggestion Card
                if (msg.foodRecommendation != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.babyPink,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.rosePink.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      msg.foodRecommendation!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],

                // Action Prompt Buttons
                if (msg.actionButtons != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: msg.actionButtons!
                        .map(
                          (btnText) => GestureDetector(
                            onTap: () => _sendMessage(btnText),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.softPurple.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                btnText,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.softPurple,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptChip(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(
          text,
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.softPurple),
        ),
        backgroundColor: AppColors.softLavender.withValues(alpha: 0.5),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _sendMessage(text),
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    ref.read(kyraMessagesProvider.notifier).sendMessage(text.trim());
    _textController.clear();
    setState(() => _isListeningVoice = false);
  }

  void _showLabReportScanModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.document_scanner_rounded,
              size: 48,
              color: AppColors.softPurple,
            ),
            const SizedBox(height: 12),
            Text(
              'Lab Report AI Scanner',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload or scan your blood panel, thyroid report, or PCOS test for instant AI interpretation.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _sendMessage(
                  'Kyra, analyze my uploaded blood test lab report.',
                );
              },
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Simulate Report Upload & Analysis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.softPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
