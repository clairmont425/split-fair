import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/room.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'room_edit_sheet.dart';
import 'results_screen.dart';
import 'saved_configs_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: AppColors.surfaceVariant,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, state),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildRentInput(context, state),
                    const SizedBox(height: 12),
                    _buildAddressInput(context, state),
                    const SizedBox(height: 24),
                    _buildRoomsList(context, state),
                    const SizedBox(height: 16),
                    _buildAddRoomButton(context, state),
                    const SizedBox(height: 24),
                    _buildCalculateButton(context, state),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, AppState state) {
    return SliverAppBar(
      backgroundColor: AppColors.surface,
      pinned: true,
      expandedHeight: 120,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Split Fair', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.w700)),
            Text('Fair rent for every room', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => showModalBottomSheet(
            context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
            builder: (_) => ChangeNotifierProvider.value(value: state, child: const SavedConfigsSheet()),
          ),
          icon: Badge(
            isLabelVisible: state.savedConfigs.isNotEmpty,
            label: Text('${state.savedConfigs.length}'),
            child: const Icon(Icons.bookmark_rounded, size: 22),
          ),
          tooltip: 'Saved configs',
        ),
        IconButton(onPressed: () => _showResetDialog(context, state), icon: const Icon(Icons.refresh_rounded, size: 22)),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildRentInput(BuildContext context, AppState state) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader(label: 'Total monthly rent'),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: CurrencyField(value: state.totalRent, label: 'Monthly total', onChanged: state.setTotalRent),
      ),
    ]).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildAddressInput(BuildContext context, AppState state) {
    return _AddressField(
      initialValue: state.address,
      onChanged: state.setAddress,
    ).animate().fadeIn(duration: 300.ms, delay: 25.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildRoomsList(BuildContext context, AppState state) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        label: '${state.rooms.length} rooms',
        trailing: IconButton(
          onPressed: () => _showScoringExplainer(context),
          icon: const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.textTertiary),
          tooltip: 'How scoring works',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
      ),
      const SizedBox(height: 8),
      ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.rooms.length,
        onReorder: state.reorderRooms,
        proxyDecorator: (child, idx, anim) => Material(elevation: 8, borderRadius: BorderRadius.circular(16), child: child),
        itemBuilder: (context, i) {
          final room = state.rooms[i];
          final color = AppColors.roomColors[i % AppColors.roomColors.length];
          return KeyedSubtree(
            key: ValueKey(room.id),
            child: _RoomTile(
              room: room, color: color, index: i,
              onEdit: () => _openRoomEdit(context, state, room.id),
              onDelete: state.rooms.length > 2 ? () => state.removeRoom(room.id) : null,
            ).animate().fadeIn(duration: 280.ms, delay: (40 + i * 65).ms).slideX(begin: 0.04, end: 0),
          );
        },
      ),
    ]);
  }

  Widget _buildAddRoomButton(BuildContext context, AppState state) {
    return OutlinedButton.icon(
      onPressed: state.rooms.length < 6 ? state.addRoom : null,
      icon: const Icon(Icons.add_rounded, size: 20),
      label: Text(state.rooms.length < 6 ? 'Add another room' : 'Maximum 6 rooms'),
      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildCalculateButton(BuildContext context, AppState state) {
    final isReady = state.rooms.length >= 2 && state.totalRent > 0;
    return ElevatedButton(
      onPressed: isReady ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultsScreen())) : null,
      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.calculate_rounded, size: 20),
        SizedBox(width: 8),
        Text('Calculate fair split'),
      ]),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideY(begin: 0.05, end: 0);
  }

  void _showScoringExplainer(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => const _ScoringExplainerSheet(),
    );
  }

  void _openRoomEdit(BuildContext context, AppState state, String roomId) {
    final room = state.rooms.firstWhere((r) => r.id == roomId);
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => RoomEditSheet(room: room, onSave: (updated) => state.updateRoom(roomId, updated)),
    );
  }

  void _showResetDialog(BuildContext context, AppState state) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Reset everything?'),
      content: const Text('This will clear all rooms and start fresh.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () { state.reset(); Navigator.pop(ctx); },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, minimumSize: const Size(80, 40)),
          child: const Text('Reset'),
        ),
      ],
    ));
  }
}

// ─── Scoring Explainer Sheet ─────────────────────────────────────────────────

class _ScoringExplainerSheet extends StatelessWidget {
  const _ScoringExplainerSheet();

  static const _rows = [
    ('Square footage', '1 pt per sqft'),
    ('Private bathroom', '+40 pts'),
    ('Parking spot', '+30 pts'),
    ('Balcony / patio', '+20 pts'),
    ('Walk-in closet', '+15 pts'),
    ('A/C unit', '+10 pts'),
    ('Floor bonus', '+2 pts/floor (max +12)'),
    ('Natural light (1–10)', '×3 pts each'),
    ('Noise level (1–10)', '×2 pts each'),
    ('Storage space (1–10)', '×1.5 pts each'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderMed, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.calculate_rounded, size: 18, color: AppColors.primary)),
          const SizedBox(width: 12),
          Text('How scoring works', style: Theme.of(context).textTheme.titleLarge),
        ]),
        const SizedBox(height: 8),
        Text('Each room earns points based on size and features. Your share of rent = your room\'s points ÷ total points.',
          style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
          child: Column(children: _rows.asMap().entries.map((e) {
            final isLast = e.key == _rows.length - 1;
            return Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                child: Row(children: [
                  Expanded(child: Text(e.value.$1, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14))),
                  Text(e.value.$2, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary)),
                ]),
              ),
              if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
            ]);
          }).toList()),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
          child: Text('Example: 180 sqft + private bath = 180 + 40 = 220 pts. If total is 400 pts, this room pays 55% of rent.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primaryDark, fontSize: 13)),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          child: const Text('Got it'),
        ),
      ]),
    );
  }
}

class _AddressField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  const _AddressField({required this.initialValue, required this.onChanged});
  @override
  State<_AddressField> createState() => _AddressFieldState();
}

class _AddressFieldState extends State<_AddressField> {
  late final TextEditingController _ctrl;
  @override
  void initState() { super.initState(); _ctrl = TextEditingController(text: widget.initialValue); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _ctrl,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Property address (optional)',
        hintText: 'e.g. 123 Main St, Apt 4B',
        prefixIcon: Icon(Icons.location_on_outlined, size: 20),
      ),
      onChanged: widget.onChanged,
    );
  }
}

class _RoomTile extends StatelessWidget {
  final Room room;
  final Color color;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  const _RoomTile({super.key, required this.room, required this.color, required this.index, required this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Material(
        color: Colors.transparent, borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onEdit, borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Text(room.tenant.isNotEmpty ? room.tenant[0].toUpperCase() : '?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(room.tenant, style: Theme.of(context).textTheme.titleMedium),
                Row(children: [
                  Text(room.name, style: Theme.of(context).textTheme.bodyMedium),
                  const Text(' · '),
                  Text('${room.sqft.toInt()} sqft', style: Theme.of(context).textTheme.bodyMedium),
                  if (room.hasPrivateBath) ...[const Text(' · '), const Icon(Icons.bathtub_rounded, size: 12, color: AppColors.textTertiary)],
                ]),
              ])),
              if (onDelete != null) IconButton(onPressed: onDelete, icon: Icon(Icons.remove_circle_outline_rounded, size: 20, color: AppColors.error.withOpacity(0.7))),
              const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textTertiary),
            ]),
          ),
        ),
      ),
    );
  }
}