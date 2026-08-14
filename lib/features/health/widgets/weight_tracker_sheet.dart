import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../models/health_entries.dart';
import '../providers/health_data_provider.dart';
import '../services/health_analytics.dart';
import 'health_form_helpers.dart';
import 'tracker_meta.dart';

/// Weight logging form with history and a simple trend line (fl_chart).
/// The form allows backdated entries, and changes are never labelled as
/// good or bad - weight fluctuations are normal.
class WeightSheet extends ConsumerStatefulWidget {
  final WeightEntry? entry;

  const WeightSheet({super.key, this.entry});

  static Future<bool?> show(BuildContext context, {WeightEntry? entry}) {
    return showHealthSheet<bool>(context, WeightSheet(entry: entry));
  }

  @override
  ConsumerState<WeightSheet> createState() => _WeightSheetState();
}

class _WeightSheetState extends ConsumerState<WeightSheet> {
  final TextEditingController _weightController = TextEditingController();

  late DateTime _date;
  String _unit = 'kg';
  String? _editingId;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _date = dateOnly(entry?.date ?? DateTime.now());
    if (entry != null) {
      _editingId = entry.id;
      _unit = entry.unit;
      _weightController.text =
          (entry.weight % 1 == 0)
              ? entry.weight.toInt().toString()
              : entry.weight.toString();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  List<WeightEntry> get _history => ref.watch(healthDataProvider).weight;

  void _startEdit(WeightEntry entry) {
    setState(() {
      _editingId = entry.id;
      _unit = entry.unit;
      _date = dateOnly(entry.date);
      _weightController.text =
          (entry.weight % 1 == 0)
              ? entry.weight.toInt().toString()
              : entry.weight.toString();
    });
  }

  void _resetForm() {
    setState(() {
      _editingId = null;
      _unit = 'kg';
      _date = dateOnly(DateTime.now());
      _weightController.clear();
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    final weight = double.tryParse(_weightController.text.trim());
    if (weight == null || weight <= 0) {
      setState(() => _errorMessage = 'Please enter a valid weight.');
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    final existing = _editingId == null
        ? null
        : _history.where((e) => e.id == _editingId).firstOrNull;

    final error = await ref.read(healthDataProvider.notifier).saveWeight(
          existing: widget.entry ?? existing,
          date: _date,
          weight: weight,
          unit: _unit,
        );

    if (!mounted) return;
    if (error != null) {
      setState(() {
        _saving = false;
        _errorMessage = error;
      });
      return;
    }

    _resetForm();
    setState(() => _saving = false);
    showSavedSnack(context, 'Weight saved.');
  }

  Future<void> _delete(WeightEntry entry) async {
    final ok = await confirmDeleteEntry(context, 'this weight entry');
    if (!ok || !mounted) return;
    final error =
        await ref.read(healthDataProvider.notifier).deleteWeight(entry.id);
    if (!mounted) return;
    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      showSavedSnack(context, 'Weight entry deleted.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = _history.take(12).toList();
    final month = HealthAnalytics.thisMonth(_history, DateTime.now());
    final change = month.weightChangeKg;

    return HealthSheetScaffold(
      title: 'Weight',
      icon: TrackerMeta.weight.icon,
      color: TrackerMeta.weight.color,
      subtitle: _editingId == null ? 'Log your weight' : 'Edit weight entry',
      saving: _saving,
      saveLabel: _editingId == null
          ? HealthTrackerType.weight.saveLabel
          : 'Update Weight',
      errorMessage: _errorMessage,
      onSave: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (history.length >= 2) ...[
            _buildTrendChart(history),
            const SizedBox(height: 10),
          ],
          if (change != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: TrackerMeta.weight.color.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: TrackerMeta.weight.color.withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_flat_rounded,
                    color: TrackerMeta.weight.color,
                    size: 19,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This month: '
                      '${change.toStringAsFixed(1)} kg change from '
                      '${month.firstWeight!.weight.toStringAsFixed(1)} '
                      '${month.firstWeight!.unit} to '
                      '${month.lastWeight!.weight.toStringAsFixed(1)} '
                      '${month.lastWeight!.unit}.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          HealthDateField(
            date: _date,
            label: 'Weight date',
            onChanged: (d) => setState(() => _date = dateOnly(d)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: HealthTextField(
                  controller: _weightController,
                  labelText: 'Weight',
                  hintText: 'e.g. 62.4',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [decimalFormatter],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OptionChips(
                  options: const ['kg', 'lb'],
                  selected: _unit,
                  onChanged: (v) => setState(() => _unit = v),
                  selectedColor: TrackerMeta.weight.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (history.isNotEmpty) ...[
            const SheetSectionTitle('History'),
            const SizedBox(height: 8),
            ...history.map(
              (entry) => LoggedEntryRow(
                icon: TrackerMeta.weight.icon,
                color: TrackerMeta.weight.color,
                title:
                    '${entry.weight % 1 == 0 ? entry.weight.toInt() : entry.weight} ${entry.unit}',
                subtitle: '${entry.date.day} ${_monthName(entry.date)} ${entry.date.year}',
                onTap: () => _startEdit(entry),
                onDelete: () => _delete(entry),
              ),
            ),
          ],
          Text(
            'Weight fluctuates naturally. SYNCO simply records your numbers '
            'and never labels changes as good or bad.',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart(List<WeightEntry> history) {
    final points = history.reversed.toList();
    final minKg = points.map((e) => e.weightKg).reduce(
          (a, b) => a < b ? a : b,
        );
    final maxKg = points.map((e) => e.weightKg).reduce(
          (a, b) => a > b ? a : b,
        );
    final range = (maxKg - minKg).clamp(0.5, 20.0);

    return Container(
      height: 140,
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderGrey.withValues(alpha: 0.5),
        ),
      ),
      child: LineChart(
        LineChartData(
          minY: minKg - range * 0.35,
          maxY: maxKg + range * 0.35,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((spot) {
                final e = points[spot.x.toInt()];
                return LineTooltipItem(
                  '${e.weight.toStringAsFixed(1)} ${e.unit}',
                  TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < points.length; i++)
                  FlSpot(i.toDouble(), points[i].weightKg),
              ],
              isCurved: true,
              curveSmoothness: 0.25,
              color: TrackerMeta.weight.color,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: TrackerMeta.weight.color.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _monthName(DateTime d) =>
      const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1];
}