import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';

class PaywallSheet extends StatefulWidget {
  const PaywallSheet({super.key});
  @override
  State<PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends State<PaywallSheet> {
  bool _loading = false;

  Future<void> _purchase() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      context.read<AppState>().unlockIap();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF export unlocked!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderMed, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 28),
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.picture_as_pdf_rounded, size: 36, color: AppColors.accent),
        ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
        const SizedBox(height: 20),
        Text('Unlock PDF Export', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('Get a beautiful, shareable PDF of your rent split.', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        ...[('Printable PDF with all room details', Icons.print_rounded), ('Professional layout', Icons.home_work_rounded), ('One-time purchase, yours forever', Icons.all_inclusive_rounded)].map((f) =>
          Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
            Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)), child: Icon(f.$2, size: 16, color: AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(child: Text(f.$1, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15))),
          ]))),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _loading ? null : _purchase,
          child: _loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) : const Text('Unlock for \$1.99'),
        ),
        const SizedBox(height: 12),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Maybe later')),
      ]),
    );
  }
}