import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AnalyticsChart extends StatefulWidget {
  final List<String> labels;
  final List<double> revenueData;
  final List<double> userData;
  final List<double> deviceData;

  const AnalyticsChart({
    super.key,
    required this.labels,
    required this.revenueData,
    required this.userData,
    required this.deviceData,
  });

  @override
  State<AnalyticsChart> createState() => _AnalyticsChartState();
}

class _AnalyticsChartState extends State<AnalyticsChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  int _selectedTab = 0;
  final _tabs = ['Revenue', 'Users', 'Devices'];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<double> get _currentData {
    switch (_selectedTab) {
      case 0:
        return widget.revenueData;
      case 1:
        return widget.userData;
      case 2:
        return widget.deviceData;
      default:
        return widget.revenueData;
    }
  }

  Color get _lineColor {
    switch (_selectedTab) {
      case 0:
        return AppColors.incomeGrad1;
      case 1:
        return AppColors.userGrad1;
      case 2:
        return AppColors.deviceGrad1;
      default:
        return AppColors.accent;
    }
  }

  void _switchTab(int i) {
    setState(() => _selectedTab = i);
    _ctrl.reset();
    _ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentData = _currentData.isEmpty ? [0.0, 0.0] : _currentData;
    final lastVal = currentData.last;
    final prevVal =
        currentData.length > 1 ? currentData[currentData.length - 2] : 0.0;
    final change = prevVal == 0
        ? (lastVal == 0 ? 0.0 : 100.0)
        : ((lastVal - prevVal) / prevVal * 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ANALYTICS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: isDark
                      ? AppColors.textMuted
                      : AppColors.textDarkSecondary,
                ),
              ),
              Row(
                children: List.generate(_tabs.length, (i) {
                  final sel = i == _selectedTab;
                  return GestureDetector(
                    onTap: () => _switchTab(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: sel
                            ? _lineColor.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel
                              ? _lineColor.withOpacity(0.4)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        _tabs[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: sel ? _lineColor : AppColors.textMuted,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _selectedTab == 0
                    ? '₹${(lastVal / 1000).toStringAsFixed(0)}K'
                    : lastVal.toInt().toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: isDark ? AppColors.textPrimary : AppColors.textDark,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      change >= 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 14,
                      color: change >= 0 ? AppColors.success : AppColors.error,
                    ),
                    Text(
                      ' ${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color:
                            change >= 0 ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => CustomPaint(
                size: const Size(double.infinity, 120),
                painter: _ChartPainter(
                  data: _currentData,
                  progress: _anim.value,
                  lineColor: _lineColor,
                  isDark: isDark,
                  labels: widget.labels,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> data;
  final double progress;
  final Color lineColor;
  final bool isDark;
  final List<String> labels;

  _ChartPainter({
    required this.data,
    required this.progress,
    required this.lineColor,
    required this.isDark,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final chartH = size.height - 22;
    final minV = data.reduce(min);
    final maxV = data.reduce(max);
    final range = maxV - minV == 0 ? 1 : maxV - minV;
    final padded = range * 0.15;
    final effectiveMin = minV - padded;
    final effectiveMax = maxV + padded;
    final effectiveRange = effectiveMax - effectiveMin;

    final stepX = data.length == 1 ? 0.0 : size.width / (data.length - 1);

    List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = chartH - ((data[i] - effectiveMin) / effectiveRange) * chartH;
      points.add(Offset(x, y));
    }

    // Grid lines
    final gridPaint = Paint()
      ..color = (isDark ? AppColors.darkBorder : AppColors.lightBorder)
          .withOpacity(0.6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (int g = 0; g < 3; g++) {
      final y = chartH * (1 - g / 2);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Animated clipping
    final animCount =
        (progress * (points.length - 1)).clamp(0.0, data.length - 1.0);
    final fullIdx = animCount.floor();
    final frac = animCount - fullIdx;
    List<Offset> animPoints = points.sublist(0, fullIdx + 1);
    if (fullIdx < points.length - 1) {
      animPoints.add(Offset.lerp(points[fullIdx], points[fullIdx + 1], frac)!);
    }

    if (animPoints.length < 2) return;

    // Fill path
    final fillPath = Path();
    fillPath.moveTo(animPoints.first.dx, chartH);
    fillPath.lineTo(animPoints.first.dx, animPoints.first.dy);
    for (int i = 1; i < animPoints.length; i++) {
      final cp1 = Offset(
          (animPoints[i - 1].dx + animPoints[i].dx) / 2, animPoints[i - 1].dy);
      final cp2 = Offset(
          (animPoints[i - 1].dx + animPoints[i].dx) / 2, animPoints[i].dy);
      fillPath.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, animPoints[i].dx, animPoints[i].dy);
    }
    fillPath.lineTo(animPoints.last.dx, chartH);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withOpacity(0.25), lineColor.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, chartH));
    canvas.drawPath(fillPath, fillPaint);

    // Line path
    final linePath = Path();
    linePath.moveTo(animPoints.first.dx, animPoints.first.dy);
    for (int i = 1; i < animPoints.length; i++) {
      final cp1 = Offset(
          (animPoints[i - 1].dx + animPoints[i].dx) / 2, animPoints[i - 1].dy);
      final cp2 = Offset(
          (animPoints[i - 1].dx + animPoints[i].dx) / 2, animPoints[i].dy);
      linePath.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, animPoints[i].dx, animPoints[i].dy);
    }
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // Dot on last visible point
    final lastPt = animPoints.last;
    canvas.drawCircle(lastPt, 5, Paint()..color = lineColor);
    canvas.drawCircle(lastPt, 3,
        Paint()..color = isDark ? AppColors.darkCard : AppColors.lightCard);

    // X-axis labels
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < labels.length; i++) {
      tp.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          fontSize: 10,
          color: isDark ? AppColors.textMuted : AppColors.textDarkSecondary,
          fontWeight: FontWeight.w500,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(i * stepX - tp.width / 2, chartH + 6));
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.progress != progress ||
      old.data != data ||
      old.labels != labels ||
      old.lineColor != lineColor ||
      old.isDark != isDark;
}
