import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';

class PartnerLinkDialog extends ConsumerStatefulWidget {
  const PartnerLinkDialog({super.key});

  @override
  ConsumerState<PartnerLinkDialog> createState() => _PartnerLinkDialogState();
}

class _PartnerLinkDialogState extends ConsumerState<PartnerLinkDialog> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.babyPink,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: AppColors.rosePink,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Link With Partner',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Share your cycle phases, mood updates, and fertility reminders with your partner for better support.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textMedium,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            if (user.isPartnerLinked) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.softLavender.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.softPurple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Linked with ${user.partnerName ?? 'Partner'}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Code: ${user.partnerCode}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(userProfileProvider.notifier).unlinkPartner();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.link_off_rounded, color: Colors.redAccent),
                label: const Text('Unlink Partner', style: TextStyle(color: Colors.redAccent)),
              ),
            ] else ...[
              // Pair Code Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR SYNC CODE',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLight,
                          ),
                        ),
                        Text(
                          user.partnerCode ?? 'HS-8942',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.softPurple,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: AppColors.softPurple),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: user.partnerCode ?? 'HS-8942'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sync Code copied to clipboard!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Partner Name',
                  hintText: 'e.g. Alex',
                  prefixIcon: const Icon(Icons.person_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Enter Partner Code',
                  hintText: 'e.g. HS-4321',
                  prefixIcon: const Icon(Icons.qr_code_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  final code = _codeController.text.trim();
                  if (name.isNotEmpty && code.isNotEmpty) {
                    ref.read(userProfileProvider.notifier).linkPartner(code, name);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Successfully linked with $name! 💖')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.softPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Connect & Sync', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
