import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final double growth;
  final List<Color> gradientColors;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isInverse;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.growth,
    required this.gradientColors,
    required this.icon,
    this.onTap,
    this.isInverse = false,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverCtrl;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPositive =
        widget.isInverse ? widget.growth <= 0 : widget.growth >= 0;
    final growthColor = isPositive ? AppColors.success : AppColors.error;
    final growthIcon = widget.growth >= 0
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;
    final growthText =
        '${widget.growth >= 0 ? '+' : ''}${widget.growth.toStringAsFixed(1)}%';

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.gradientColors[0].withOpacity(0.15),
                widget.gradientColors[1].withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.gradientColors[0].withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, size: 18, color: Colors.white),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: widget.gradientColors[0].withOpacity(0.6),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                widget.value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: widget.gradientColors[0],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(growthIcon, size: 13, color: growthColor),
                  const SizedBox(width: 3),
                  Text(
                    growthText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: growthColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
