import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/queries/workout_queries.dart';
import '../../domain/epoch_day.dart';
import '../../domain/heatmap.dart';

/// "ANNUAL LOG": the current year's heatmap. Display only, because its cells
/// are too small to tap. Past sessions are on the History tab.
class HeatmapSection extends ConsumerWidget {
  const HeatmapSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final today = ref.watch(todayProvider);
    final currentYear = EpochDay.toDate(today).year;
    final data = ref.watch(heatmapProvider(currentYear));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('ANNUAL LOG', style: text.labelSmall),
            const Spacer(),
            Text(
              '$currentYear',
              style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        data.when(
          loading: () => const SizedBox(height: 120),
          error: (e, _) => Text('Could not load heatmap: $e'),
          data: (d) => HeatmapGrid(data: d, todayDay: today),
        ),
        const SizedBox(height: 8),
        const HeatmapLegend(),
      ],
    );
  }
}

class HeatmapLegend extends StatelessWidget {
  const HeatmapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Less', style: text.bodySmall),
          const SizedBox(width: 6),
          for (final c in AppColors.heatmap)
            Container(
              width: 12,
              height: 12,
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
    );
  }
}

/// Geometry for painting the grid: the whole year, January to December.
class _Layout {
  _Layout({required this.year, required double available})
      : firstDay = Heatmap.firstDay(year),
        lastDay = Heatmap.lastDay(year),
        firstWeek = EpochDay.weekStart(Heatmap.firstDay(year)),
        cols = Heatmap.columns(year),
        pitch = Heatmap.cellPitch(
          available: available,
          columns: Heatmap.columns(year),
        );

  /// Width of the fixed weekday-label column on the left.
  static const double labelWidth = 18;

  /// Height reserved above the grid for month names.
  static const double topPad = 18;

  final int year;
  final int firstDay;
  final int lastDay;
  final int firstWeek;
  final int cols;

  /// Distance between neighbouring cells.
  final double pitch;

  double get gap => math.max(1.5, pitch * 0.16);
  double get gridWidth => cols * pitch;
  double get height => topPad + 7 * pitch;
}

/// The heatmap itself, painted on single canvases and display only.
///
/// It always shows the whole year, so days logged in the past are never cut
/// off. Cells are a comfortable size, so a full year is wider than a phone: it
/// scrolls sideways, opening on the current week.
class HeatmapGrid extends StatelessWidget {
  const HeatmapGrid({super.key, required this.data, required this.todayDay});

  final HeatmapData data;
  final int todayDay;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth - _Layout.labelWidth;
        final layout = _Layout(year: data.year, available: available);

        final grid = RepaintBoundary(
          child: CustomPaint(
            size: Size(layout.gridWidth, layout.height),
            painter: _GridPainter(layout, data, todayDay),
          ),
        );

        final Widget body;
        if (layout.gridWidth <= available) {
          body = Align(alignment: Alignment.centerLeft, child: grid);
        } else {
          final isCurrentYear = data.year == EpochDay.toDate(todayDay).year;
          body = _HorizontalScroll(
            key: ValueKey(data.year),
            initialOffset: Heatmap.initialScrollOffset(
              currentColumn:
                  isCurrentYear ? (todayDay - layout.firstWeek) ~/ 7 : null,
              pitch: layout.pitch,
              viewportWidth: available,
              contentWidth: layout.gridWidth,
            ),
            child: grid,
          );
        }

        return SizedBox(
          height: layout.height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weekday names stay put while the grid scrolls.
              SizedBox(
                width: _Layout.labelWidth,
                height: layout.height,
                child: CustomPaint(painter: _WeekdayLabelsPainter(layout)),
              ),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}

class _HorizontalScroll extends StatefulWidget {
  const _HorizontalScroll({
    super.key,
    required this.initialOffset,
    required this.child,
  });

  final double initialOffset;
  final Widget child;

  @override
  State<_HorizontalScroll> createState() => _HorizontalScrollState();
}

class _HorizontalScrollState extends State<_HorizontalScroll> {
  late final ScrollController _controller =
      ScrollController(initialScrollOffset: widget.initialOffset);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      child: widget.child,
    );
  }
}

const _labelStyle = TextStyle(
  fontFamily: AppTheme.fontFamily,
  fontSize: 10,
  color: AppColors.textMuted,
);

TextPainter _textPainter(String text) => TextPainter(
      text: TextSpan(text: text, style: _labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();

/// Squares, today's outline and month names.
class _GridPainter extends CustomPainter {
  _GridPainter(this.layout, this.data, this.todayDay);

  final _Layout layout;
  final HeatmapData data;
  final int todayDay;

  @override
  void paint(Canvas canvas, Size size) {
    final l = layout;
    final paint = Paint();
    final square = l.pitch - l.gap;
    final radius = Radius.circular(square * 0.22);

    for (var day = l.firstDay; day <= l.lastDay; day++) {
      final col = (day - l.firstWeek) ~/ 7;
      final row = EpochDay.weekdayOf(day) - 1;
      final rect = Rect.fromLTWH(
        col * l.pitch,
        _Layout.topPad + row * l.pitch,
        square,
        square,
      );
      paint
        ..style = PaintingStyle.fill
        ..color = AppColors.heatmap[Heatmap.tier(data.setCounts[day] ?? 0)];
      canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);

      if (day == todayDay) {
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = AppColors.todayOutline;
        canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);
      }
    }

    // A month name above the first column of each month.
    for (var month = 1; month <= 12; month++) {
      final first = EpochDay.fromDate(DateTime(l.year, month, 1));
      final col = (first - l.firstWeek) ~/ 7;
      _textPainter(Fmt.month(month).substring(0, 3))
          .paint(canvas, Offset(col * l.pitch, 0));
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) =>
      old.data != data ||
      old.todayDay != todayDay ||
      old.layout.pitch != layout.pitch;
}

/// M, W, F and S beside rows 0, 2, 4 and 6.
class _WeekdayLabelsPainter extends CustomPainter {
  _WeekdayLabelsPainter(this.layout);

  final _Layout layout;

  @override
  void paint(Canvas canvas, Size size) {
    const rows = {0: 'M', 2: 'W', 4: 'F', 6: 'S'};
    rows.forEach((row, name) {
      final tp = _textPainter(name);
      final y = _Layout.topPad + row * layout.pitch + (layout.pitch - tp.height) / 2;
      tp.paint(canvas, Offset(0, y));
    });
  }

  @override
  bool shouldRepaint(_WeekdayLabelsPainter old) => old.layout.pitch != layout.pitch;
}
