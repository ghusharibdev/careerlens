import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;

  const AppCard({super.key, required this.child, this.padding, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: child,
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final bool outlined;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.outlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : AppTheme.accent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: outlined ? AppTheme.border : AppTheme.accent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.bg),
              )
            else ...[
              if (icon != null) ...[
                Icon(icon, size: 18, color: outlined ? AppTheme.textPrimary : AppTheme.bg),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: outlined ? AppTheme.textPrimary : AppTheme.bg,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ScoreGauge extends StatelessWidget {
  final int score;
  const ScoreGauge({super.key, required this.score});

  Color get _color {
    if (score >= 70) return AppTheme.success;
    if (score >= 45) return AppTheme.warning;
    return AppTheme.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _color, width: 3),
        color: _color.withOpacity(0.08),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$score', style: TextStyle(color: _color, fontSize: 22, fontWeight: FontWeight.w700)),
            Text('%', style: TextStyle(color: _color.withOpacity(0.7), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'applied': return AppTheme.textSecondary;
      case 'interview': return AppTheme.warning;
      case 'offer': return AppTheme.success;
      case 'rejected': return AppTheme.danger;
      default: return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(color: _color, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    );
  }
}
