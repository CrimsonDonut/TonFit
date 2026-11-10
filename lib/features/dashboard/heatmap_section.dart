import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/queries/workout_queries.dart';
import '../../domain/epoch_day.dart';
import '../../domain/heatmap.dart';

/// "ANNUAL LOG": year switcher, the heatmap grid and a Less/More legend.
class HeatmapSection extends ConsumerWidget {
  const HeatmapSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final today = ref.watch(todayProvider);
    final currentYear = EpochDay.toDate(today).year;
    final year = ref.watch(selectedYearProvider) ?? currentYear;
    final data = ref.watch(heatmapProvider(year));
    final firstYear = data.valueOrNull?.firstYear ?? year;
    final years = [for (var y = firstYear; y <= currentYear; y++) y];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('ANNUAL LOG', style: text.labelSmall),
            const Spacer(),
            for (var i = 0; i < years.length; i++) ...[
              if (i > 0)
                Text(' · ', style: text.bodySmall),
              InkWell(
                onTap: () => ref.read(selectedYearProvider.notifier).state = years[i],
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '${years[i]}',
                    style: years[i] == year
                        ? text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.textStrong,
                          )
                        : text.bodySmall,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        data.when(
          loading: () => const SizedBox(height: 120),
          error: (e, _) => Text('Could not load heatmap: $e'),
          data: (d) => HeatmapGrid(
            data: d,
            todayDay: today,
            onTapDay: (day) => context.push('/day/$day'),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Less', style: text.bodySmall),
              const SizedBox(width: 6),
              for (final c in AppColors.heatmap)
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              const SizedBox(width: 6),
              Text('More', style: text.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

/// Geometry shared by painting and tap detection.
class _Layout {
  _Layout._({
    required this.year,
    required this.firstDay,
    required this.lastDay,
    required this.firstWeek,
    required this.cols,
    required this.cell,
  });

  factory _Layout(int year, double width) {
    final firstDay = EpochDay.fromDate(DateTime(year, 1, 1));
    final lastDay = EpochDay.fromDate(DateTime(year, 12, 31));
    final firstWeek = EpochDay.weekStart(firstDay);
    final cols = (EpochDay.weekStart(lastDay) - firstWeek) ~/ 7 + 1;
    final cell = (width - leftPad) / cols;
    return _Layout._(
      year: year,
      firstDay: firstDay,
      lastDay: lastDay,
      firstWeek: firstWeek,
      cols: cols,
      cell: cell,
    );
  }

  static const double leftPad = 16;
  static const double topPad = 16;

  final int year;
  final int firstDay;
  final int lastDay;
  final int firstWeek;
  final int cols;
  final double cell;

  double get gap => math.max(1.0, cell * 0.18);
  double get height => topPad + 7 * cell;

  /// The day under [p], or null outside the grid.
  int? dayAt(Offset p) {
    final x = p.dx - leftPad;
    final y = p.dy - topPad;
    if (x < 0 || y < 0) return null;
    final col = (x / cell).floor();
    final row = (y / cell).floor();
    if (row > 6 || col >= cols) return null;
    final day = firstWeek + col * 7 + row;
    if (day < firstDay || day > lastDay) return null;
    return day;
  }
}

class HeatmapGrid extends StatelessWidget {
  const HeatmapGrid({
    super.key,
    required this.data,
    required this.todayDay,
    required this.onTapDay,
  });

  final HeatmapData data;
  final int todayDay;
  final void Function(int day) onTapDay;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _Layout(data.year, constraints.maxWidth);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) {
            final day = layout.dayAt(details.localPosition);
            // Only days that have a session open something.
            if (day != null && data.setCounts.containsKey(day)) onTapDay(day);
          },
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size(constraints.maxWidth, layout.height),
              painter: _HeatmapPainter(layout, data, todayDay),
            ),
          ),
        );
      },
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter(this.layout, this.data, this.todayDay);

  final _Layout layout;
  final HeatmapData data;
  final int todayDay;

  static const _labelStyle = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 9,
    color: AppColors.textMuted,
  );

  void _label(Canvas canvas, String text, Offset at) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: _labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final l = layout;
    final paint = Paint();
    final radius = Radius.circular(l.cell * 0.2);

    // One rounded square per day of the year.
    for (var day = l.firstDay; day <= l.lastDay; day++) {
      final col = (day - l.firstWeek) ~/ 7;
      final row = EpochDay.weekdayOf(day) - 1;
      final rect = Rect.fromLTWH(
        _Layout.leftPad + col * l.cell,
        _Layout.topPad + row * l.cell,
        l.cell - l.gap,
        l.cell - l.gap,
      );
      paint
        ..style = PaintingStyle.fill
        ..color = AppColors.heatmap[Heatmap.tier(data.setCounts[day] ?? 0)];
      canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);

      if (day == todayDay) {
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = AppColors.textStrong;
        canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);
      }
    }

    // Month labels along the top.
    for (var month = 1; month <= 12; month++) {
      final first = EpochDay.fromDate(DateTime(l.year, month, 1));
      final col = (first - l.firstWeek) ~/ 7;
      _label(
        canvas,
        Fmt.month(month).substring(0, 3),
        Offset(_Layout.leftPad + col * l.cell, 0),
      );
    }

    // Weekday labels: M W F S (rows 0, 2, 4, 6).
    const rows = {0: 'M', 2: 'W', 4: 'F', 6: 'S'};
    rows.forEach((row, name) {
      _label(canvas, name, Offset(0, _Layout.topPad + row * l.cell));
    });
  }

  @override
  bool shouldRepaint(_HeatmapPainter old) =>
      old.data != data || old.todayDay != todayDay || old.layout.cell != layout.cell;
}
