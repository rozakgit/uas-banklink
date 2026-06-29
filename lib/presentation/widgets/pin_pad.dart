import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PinPad extends StatelessWidget {
  final String value;
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onComplete;
  final VoidCallback? onBiometric;

  const PinPad({
    super.key,
    required this.value,
    this.onChanged,
    this.length = 6,
    this.onComplete,
    this.onBiometric,
  });

  void _press(String key) {
    String next;
    if (key == 'del') {
      next = value.isEmpty ? '' : value.substring(0, value.length - 1);
    } else {
      if (value.length >= length) return;
      next = value + key;
    }
    onChanged?.call(next);
    if (next.length == length) {
      Future.delayed(const Duration(milliseconds: 140), () => onComplete?.call(next));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'bio', '0', 'del'];

    return Column(
      children: [
        // PIN dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(length, (i) {
            final filled = i < value.length;
            return Container(
              width: 15,
              height: 15,
              margin: const EdgeInsets.symmetric(horizontal: 7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? AppColors.bluePrimary : Colors.transparent,
                border: Border.all(
                  color: filled ? AppColors.bluePrimary : (isDark ? Colors.white24 : Colors.black26),
                  width: 2,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 28),
        // Keypad grid
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.4,
          children: keys.map((k) {
            if (k == 'bio') {
              return _KeyButton(
                onTap: () => onBiometric?.call(),
                isDark: isDark,
                child: const Icon(Icons.fingerprint_rounded, size: 28, color: AppColors.bluePrimary),
              );
            }
            if (k == 'del') {
              return _KeyButton(
                onTap: () => _press('del'),
                isDark: isDark,
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 22, color: isDark ? Colors.white54 : Colors.black54),
              );
            }
            return _KeyButton(
              onTap: () => _press(k),
              isDark: isDark,
              child: Text(
                k,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: isDark ? Colors.white : AppColors.darkSurface,
                  shadows: isDark ? const [
                    Shadow(color: Colors.white24, offset: Offset(1, 1), blurRadius: 1),
                    Shadow(color: Colors.black87, offset: Offset(-1, -1), blurRadius: 1),
                  ] : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final bool isDark;

  const _KeyButton({required this.onTap, required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
        ),
        child: Center(child: child),
      ),
    );
  }
}
