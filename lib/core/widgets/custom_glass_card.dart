import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry? borderRadius;
  final Color? backgroundColor;
  final Border? border;
  final VoidCallback? onTap;

  const CustomGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius,
    this.backgroundColor,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(24.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius as BorderRadius?,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).cardColor,
            borderRadius: effectiveBorderRadius,
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 14,
                offset: Offset(0, 6),
              )
            ],
            border: border ??
                Border.all(
                  color: AppColors.borderGrey.withValues(alpha: 0.4),
                  width: 1,
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}
