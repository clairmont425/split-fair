import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/app_state.dart';
import '../models/pdf_service.dart';
import '../models/split_result.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/score_breakdown.dart';
import 'paywall_sheet.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      final results = state.results;
      if (results.isEmpty) return const Scaffold(body: Center(child: Text('No data')));
      final total = state.totalRent;
      return Scaffold(
        backgroundColor: AppColors.surfaceVariant,
        appBar: AppBar(
          title: const Text('Fair split'),
          actions: [
            IconButton(onPressed: () => _shareText(context, results, total), icon: const Icon(Icons.ios_share_rounded, size: 22)),
            IconButton(onPressed: () => _exportPdf(context, state, results), icon: const Icon(Icons.picture_as_pdf_rounded, size: 22)),
            const SizedBox(width: 8),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _TotalHeader(total: total, count: results.length),
            const SizedBox(height: 20),
            const SectionHeader(label: 'Each person pays'),
            const SizedBox(height: 8),
            ...results.asMap().entries.map((e) {
              final color = AppColors.roomColors[e.key % AppColors.roomColors.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AmountCard(name: e.value.room.name, tenant: e.value.room.tenant, amount: e.value.amount, percentage: e.value.percentage, color: color, rank: e.key + 1)
                  .animate().fadeIn(duration: 300.ms, delay: (e.key * 60).ms).slideX(begin: 0.05, end: 0),
              );
            }),
            const SizedBox(height: 20),
            _DonutCard(results: results, total: total),
            const SizedBox(height: 20),
            _BreakdownCard(results: results),
            const SizedBox(height: 20),
            _WhyCard(results: results),
            const SizedBox(height: 20),
            _ShareCard(results: results, total: total, onShareText: () => _shareText(context, results, total), onCopyText: () => _copyToClipboard(context, results, total), onExportPdf: () => _exportPdf(context, state, results), isUnlocked: state.iapUnlocked),
            const SizedBox(height: 40),
          ],
        ),
      );
    });
  }

  String _buildShareText(List<SplitResult> results, double total) {
    final lines = results.map((r) => '${r.room.tenant} (${r.room.name}): \$${r.amount.toStringAsFixed(2)} (${(r.percentage * 100).toStringAsFixed(1)}%)').join('\n');
    return 'Fair Rent Split — Total \$${total.toStringAsFixed(2)}\n\n$lines\n\nCalculated with Split Fair';
  }

  void _shareText(BuildContext context, List<SplitResult> results, double total) {
    Share.share(_buildShareText(results, total), subject: 'Fair rent split breakdown');
  }

  void _copyToClipboard(BuildContext context, List<SplitResult> results, double total) {
    Clipboard.setData(ClipboardData(text: _buildShareText(results, total)));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard!'), duration: Duration(seconds: 2)),
    );
  }

  Future<void> _exportPdf(BuildContext context, AppState state, List<SplitResult> results) async {
    if (state.iapUnlocked) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(const SnackBar(content: Text('Generating PDF...')));
      try {
        final bytes = await PdfService.generateSplitPdf(
          results: results,
          totalRent: state.totalRent,
          address: state.address.isNotEmpty ? state.address : null,
        );
        await Printing.sharePdf(bytes: bytes, filename: 'split_fair_rent.pdf');
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('PDF error: $e')));
      }
    } else {
      showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
        builder: (_) => ChangeNotifierProvider.value(value: state, child: const PaywallSheet()));
    }
  }
}

class _TotalHeader extends StatelessWidget {
  final double total;
  final int count;
  const _TotalHeader({required this.total, required this.count});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Total monthly rent', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.8))),
        const SizedBox(height: 6),
        Text('\$${total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Split across $count rooms', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.8))),
      ]),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1));
  }
}

class _BreakdownCard extends StatelessWidget {
  final List<SplitResult> results;
  const _BreakdownCard({required this.results});
  @override
  Widget build(BuildContext context) {
    final maxFraction = results.map((r) => r.percentage).reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Visual breakdown', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        ...results.asMap().entries.map((e) {
          final color = AppColors.roomColors[e.key % AppColors.roomColors.length];
          return BarChartRow(label: e.value.room.tenant, fraction: e.value.percentage / maxFraction, color: color, valueLabel: '${(e.value.percentage * 100).toStringAsFixed(0)}%');
        }),
      ]),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }
}

class _ShareCard extends StatelessWidget {
  final List<SplitResult> results;
  final double total;
  final VoidCallback onShareText;
  final VoidCallback onCopyText;
  final VoidCallback onExportPdf;
  final bool isUnlocked;
  const _ShareCard({required this.results, required this.total, required this.onShareText, required this.onCopyText, required this.onExportPdf, required this.isUnlocked});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Share with roommates', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text('Send the breakdown so everyone sees the math.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: onShareText,
            icon: const Icon(Icons.ios_share_rounded, size: 18),
            label: const Text('Share'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
          )),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton.icon(
            onPressed: onCopyText,
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copy'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
          )),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton.icon(
            onPressed: onExportPdf,
            icon: Icon(isUnlocked ? Icons.picture_as_pdf_rounded : Icons.lock_rounded, size: 18),
            label: Text(isUnlocked ? 'PDF' : 'PDF \$1.99'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 48), backgroundColor: isUnlocked ? AppColors.primary : AppColors.accent, foregroundColor: Colors.white),
          )),
        ]),
      ]),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }
}

// ─── Donut chart card ────────────────────────────────────────────────────────

class _DonutCard extends StatelessWidget {
  final List<SplitResult> results;
  final double total;
  const _DonutCard({required this.results, required this.total});

  @override
  Widget build(BuildContext context) {
    final slices = results.asMap().entries.map((e) {
      final color = AppColors.roomColors[e.key % AppColors.roomColors.length];
      return (color, e.value.percentage, e.value.room.tenant);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('At a glance', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 20),
        DonutChart(
          slices: slices,
          centerLabel: '\$${total.toStringAsFixed(0)}',
          centerSub: 'total',
        ),
      ]),
    ).animate().fadeIn(duration: 400.ms, delay: 180.ms);
  }
}

// ─── Why these numbers? card ─────────────────────────────────────────────────

class _WhyCard extends StatelessWidget {
  final List<SplitResult> results;
  const _WhyCard({required this.results});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Why these numbers?', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text('Tap any room to see its full score.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 14),
        ...results.asMap().entries.map((e) {
          final color = AppColors.roomColors[e.key % AppColors.roomColors.length];
          final room = e.value.room;
          // Condensed: sqft pts | feature pts | quality pts
          final sqftPts = room.sqft;
          final qualityPts = (room.naturalLightScore * 3) + (room.noiseScore * 2) + (room.storageScore * 1.5);
          final bonusPts = e.value.score - sqftPts - qualityPts;

          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (e.key > 0) const Divider(height: 20),
            Row(children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(room.tenant, style: Theme.of(context).textTheme.labelLarge),
              const Spacer(),
              Text('${e.value.score.toStringAsFixed(0)} pts total',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color)),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              _PtChip('${sqftPts.toStringAsFixed(0)} sqft', AppColors.textTertiary),
              const SizedBox(width: 6),
              if (bonusPts > 0) ...[_PtChip('+${bonusPts.toStringAsFixed(0)} features', AppColors.primary), const SizedBox(width: 6)],
              _PtChip('+${qualityPts.toStringAsFixed(0)} quality', AppColors.accent),
            ]),
          ]);
        }),
      ]),
    ).animate().fadeIn(duration: 400.ms, delay: 260.ms);
  }
}

class _PtChip extends StatelessWidget {
  final String label;
  final Color color;
  const _PtChip(this.label, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color)),
    );
  }
}