import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // يمكن أن يكون null
  final IconData? icon;
  final Color? backgroundColor;
  final double borderRadius;
  final double height;
  final double? width;

  const CustomElevatedButton({
    super.key,
    required this.text,
    this.onPressed, // أزلت required هنا لو رغبتِ في جعله اختياري
    this.icon,
    this.backgroundColor,
    this.borderRadius = 18.0,
    this.height = 55.0,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? AppColors.primaryColor,
      foregroundColor: AppColors.whiteColor,
      disabledBackgroundColor: Colors.grey.shade300, // لون الزرار لما يكون معطل
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: 0,
    );

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: icon != null
          ? ElevatedButton.icon(
              onPressed: onPressed, // الآن سيقبله الفلتر بشكل طبيعي
              style: buttonStyle,
              icon: Icon(icon, size: 20),
              label: _buildText(),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: buttonStyle,
              child: _buildText(),
            ),
    );
  }

  Widget _buildText() {
    return Text(
      text,
      style: AppTextStyle.body.copyWith(
        color: AppColors.whiteColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}