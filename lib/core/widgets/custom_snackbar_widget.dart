import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';

class AppSnackBar {
  static void showSuccess({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    _showCustomSnackBar(
      context: context,
      title: title,
      message: message,
      backgroundColor: const Color(0xFF4CAF50), // Green for Success
      icon: Icons.check_circle_outline,
    );
  }

  static void showError({
    required BuildContext context,
    String title = 'Error', // قيمة افتراضية للعنوان
    required String message,
  }) {
    _showCustomSnackBar(
      context: context,
      title: title,
      message: message,
      backgroundColor: AppColors.errorColor, // الأحمر اللي متعرف عندك في AppColors
      icon: Icons.error_outline_rounded,
    );
  }

  // ميثود خاصة (Private) عشان م نكررش الكود ونحافظ على الـ Clean Code
  static void _showCustomSnackBar({
    required BuildContext context,
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    // دي حركة صايعة عشان لو في SnackBar شغال يختفي فوراً ويظهر الجديد
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 35),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}