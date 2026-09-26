import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// BrandLogo renders the official "আমার কুষ্টিয়া" inside logo and emblem
/// using the official assets (assets/icons/app_inside_logo.png, assets/icons/app_emblem.png).
class BrandLogo extends StatelessWidget {
  final double size;
  final bool showTagline;
  final bool isLight;
  final bool iconOnly;

  const BrandLogo({
    super.key,
    this.size = 40,
    this.showTagline = true,
    this.isLight = false,
    this.iconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (iconOnly) {
      return Image.asset(
        'assets/icons/app_emblem.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        color: isLight ? Colors.white : null,
        colorBlendMode: isLight ? BlendMode.srcIn : null,
      );
    }

    final logoImage = Image.asset(
      'assets/icons/NEW-APP.png',
      height: size,
      fit: BoxFit.contain,
      color: isLight ? Colors.white : null,
      colorBlendMode: isLight ? BlendMode.srcIn : null,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/icons/new_app.png',
          height: size,
          fit: BoxFit.contain,
        );
      },
    );

    if (!showTagline) {
      return logoImage;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        logoImage,
        const SizedBox(height: 2),
        Text(
          'কুষ্টিয়ার তথ্য, সেবা ও ঐতিহ্য — এক ঠিকানায়',
          style: AppTypography.brandTagline.copyWith(
            fontSize: size * 0.26,
            color: isLight ? Colors.white70 : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
