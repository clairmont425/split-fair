import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/room.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/score_breakdown.dart';

class RoomEditSheet extends StatefulWidget {
  final Room room;
  final ValueChanged<Room> onSave;
  const RoomEditSheet({super.key, required this.room, required this.onSave});
  @override
  State<RoomEditSheet> createState() => _RoomEditSheetState();
}

class _RoomEditSheetState extends State<RoomEditSheet> {
  late Room _room;
  late TextEditingController _nameCtrl;
  late TextEditingController _tenantCtrl;
  late TextEditingController _sqftCtrl;
  late TextEditingController _floorCtrl;

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    _nameCtrl = TextEditingController(text: _room.name);
    _tenantCtrl = TextEditingController(text: _room.tenant);
    _sqftCtrl = TextEditingController(text: _room.sqft.toInt().toString());
    _floorCtrl = TextEditingController(text: _room.floorLevel > 0 ? _room.floorLevel.toString() : '');
  }

  @override
  void dispose() { _nameCtrl.dispose(); _tenantCtrl.dispose(); _sqftCtrl.dispose(); _floorCtrl.dispose(); super.dispose(); }

  void _save() {
    final parsedSqft = double.tryParse(_sqftCtrl.text) ?? _room.sqft;
    if (parsedSqft < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room must be at least 50 sqft.'), duration: Duration(seconds: 2)),
      );
      return;
    }
    widget.onSave(_room.copyWith(
      name: _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : _room.name,
      tenant: _tenantCtrl.text.trim().isNotEmpty ? _tenantCtrl.text.trim() : _room.tenant,
      sqft: parsedSqft,
      floorLevel: int.tryParse(_floorCtrl.text) ?? 0,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderMed, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(children: [
            Text('Edit room', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            const SizedBox(width: 4),
            ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(minimumSize: const Size(80, 40), padding: const EdgeInsets.symmetric(horizontal: 20)), child: const Text('Save')),
          ]),
        ),
        const Divider(),
        Flexible(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPad),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionHeader(label: 'Basics'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextFormField(controller: _tenantCtrl, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Tenant name'))),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: _nameCtrl, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Room label'))),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: TextFormField(controller: _sqftCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'Square footage', hintText: 'min 50', suffixText: 'sqft'))),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: _floorCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'Floor #', hintText: 'e.g. 3', suffixText: 'floor'))),
              ]),
              const SizedBox(height: 24),
              const SectionHeader(label: 'Features'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                FeatureChip(label: 'Private bath', icon: Icons.bathtub_rounded, selected: _room.hasPrivateBath, bonus: '+40 pts', onTap: () => setState(() { _room = _room.copyWith(hasPrivateBath: !_room.hasPrivateBath); })),
                FeatureChip(label: 'Parking spot', icon: Icons.directions_car_rounded, selected: _room.hasParking, bonus: '+30 pts', onTap: () => setState(() { _room = _room.copyWith(hasParking: !_room.hasParking); })),
                FeatureChip(label: 'Balcony / patio', icon: Icons.deck_rounded, selected: _room.hasBalcony, bonus: '+20 pts', onTap: () => setState(() { _room = _room.copyWith(hasBalcony: !_room.hasBalcony); })),
                FeatureChip(label: 'Walk-in closet', icon: Icons.checkroom_rounded, selected: _room.hasWalkInCloset, bonus: '+15 pts', onTap: () => setState(() { _room = _room.copyWith(hasWalkInCloset: !_room.hasWalkInCloset); })),
                FeatureChip(label: 'A/C unit', icon: Icons.ac_unit_rounded, selected: _room.hasAC, bonus: '+10 pts', onTap: () => setState(() { _room = _room.copyWith(hasAC: !_room.hasAC); })),
              ]),
              const SizedBox(height: 24),
              const SectionHeader(label: 'Room quality'),
              const SizedBox(height: 12),
              LabeledSlider(label: 'Natural light', value: _room.naturalLightScore, divisions: 10, format: (v) => v.toInt() < 4 ? 'Dim' : v.toInt() < 7 ? 'Good' : 'Bright', onChanged: (v) => setState(() { _room = _room.copyWith(naturalLightScore: v); })),
              const SizedBox(height: 4),
              LabeledSlider(label: 'Quietness', value: _room.noiseScore, divisions: 10, format: (v) => v.toInt() < 4 ? 'Noisy' : v.toInt() < 7 ? 'Moderate' : 'Quiet', onChanged: (v) => setState(() { _room = _room.copyWith(noiseScore: v); })),
              const SizedBox(height: 4),
              LabeledSlider(label: 'Storage space', value: _room.storageScore, divisions: 10, format: (v) => v.toInt() < 4 ? 'Minimal' : v.toInt() < 7 ? 'Average' : 'Plenty', onChanged: (v) => setState(() { _room = _room.copyWith(storageScore: v); })),
              const SizedBox(height: 24),
              ScoreBreakdown(room: _room),
            ]).animate().fadeIn(duration: 250.ms).slideY(begin: 0.03, end: 0),
          ),
        ),
      ]),
    );
  }
}