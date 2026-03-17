import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String label;
  final Widget? trailing;
  const SectionHeader({super.key, required this.label, this.trailing});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
        const Spacer(),
        if (trailing != null) trailing!,
      ]),
    );
  }
}

class CurrencyField extends StatefulWidget {
  final double value;
  final String label;
  final ValueChanged<double> onChanged;
  const CurrencyField({super.key, required this.value, required this.label, required this.onChanged});
  @override
  State<CurrencyField> createState() => _CurrencyFieldState();
}

class _CurrencyFieldState extends State<CurrencyField> {
  late TextEditingController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.toStringAsFixed(0));
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
      decoration: InputDecoration(
        labelText: widget.label,
        prefixText: '\$ ',
        prefixStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
      ),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20),
      onChanged: (v) { final parsed = double.tryParse(v); if (parsed != null) widget.onChanged(parsed); },
    );
  }
}

class LabeledSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double) format;
  final ValueChanged<double> onChanged;
  const LabeledSlider({super.key, required this.label, required this.value, this.min = 0, this.max = 10, this.divisions, required this.format, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6)),
          child: Text(format(value), style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primaryDark)),
        ),
      ]),
      const SizedBox(height: 4),
      Slider(value: value, min: min, max: max, divisions: divisions, onChanged: onChanged),
    ]);
  }
}

class FeatureChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final String bonus;
  final VoidCallback onTap;
  const FeatureChip({super.key, required this.label, required this.icon, required this.selected, required this.bonus, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.5 : 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: selected ? AppColors.primary : AppColors.textTertiary),
          const SizedBox(width: 6),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: selected ? AppColors.primaryDark : AppColors.textSecondary, fontSize: 12)),
            Text(bonus, style: TextStyle(fontSize: 10, color: selected ? AppColors.primary : AppColors.textTertiary, fontWeight: FontWeight.w500)),
          ]),
        ]),
      ),
    );
  }
}

class AmountCard extends StatefulWidget {
  final String name;
  final String tenant;
  final double amount;
  final double percentage;
  final Color color;
  final int rank;
  const AmountCard({super.key, required this.name, required this.tenant, required this.amount, required this.percentage, required this.color, required this.rank});
  @override
  State<AmountCard> createState() => _AmountCardState();
}

class _AmountCardState extends State<AmountCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: widget.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
          alignment: Alignment.center,
          child: Text(widget.tenant.isNotEmpty ? widget.tenant[0].toUpperCase() : '?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: widget.color)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.tenant, style: Theme.of(context).textTheme.titleMedium),
          Text(widget.name, style: Theme.of(context).textTheme.bodyMedium),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Text(
              '\$${(widget.amount * _anim.value).toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: widget.color, fontWeight: FontWeight.w700, fontSize: 22),
            ),
          ),
          Text('${(widget.percentage * 100).toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary)),
        ]),
      ]),
    );
  }
}

class BarChartRow extends StatelessWidget {
  final String label;
  final double fraction;
  final Color color;
  final String valueLabel;
  const BarChartRow({super.key, required this.label, required this.fraction, required this.color, required this.valueLabel});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        SizedBox(width: 72, child: Text(label, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13))),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(children: [
              Container(height: 20, color: AppColors.surfaceVariant),
              FractionallySizedBox(
                widthFactor: fraction.clamp(0.0, 1.0),
                child: Container(height: 20, decoration: BoxDecoration(color: color.withOpacity(0.85), borderRadius: BorderRadius.circular(4))),
              ),
            ]),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(width: 44, child: Text(valueLabel, textAlign: TextAlign.right, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color, fontSize: 12))),
      ]),
    );
  }
}

// ─── Donut Chart ────────────────────────────────────────────────────────────

class DonutChart extends StatelessWidget {
  /// List of (color, fraction) where fraction sums to ~1.0
  final List<(Color, double, String)> slices; // color, fraction, label
  final String centerLabel;
  final String centerSub;
  const DonutChart({super.key, required this.slices, required this.centerLabel, this.centerSub = ''});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOut,
      builder: (context, progress, _) {
        return Column(children: [
          SizedBox(
            width: 180, height: 180,
            child: CustomPaint(
              painter: _DonutPainter(slices: slices, progress: progress),
              child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(centerLabel, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                if (centerSub.isNotEmpty) Text(centerSub, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              ])),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12, runSpacing: 8, alignment: WrapAlignment.center,
            children: slices.map((s) => Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: s.$1, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text(s.$3, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 4),
              Text('${(s.$2 * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ])).toList(),
          ),
        ]);
      },
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<(Color, double, String)> slices;
  final double progress;
  const _DonutPainter({required this.slices, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const strokeWidth = 26.0;
    const gapAngle = 0.04;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startAngle = -pi / 2;

    for (final slice in slices) {
      final sweep = slice.$2 * 2 * pi * progress - gapAngle;
      if (sweep <= 0) continue;
      paint.color = slice.$1;
      canvas.drawArc(rect, startAngle + gapAngle / 2, sweep, false, paint);
      startAngle += slice.$2 * 2 * pi * progress;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.progress != progress;
}