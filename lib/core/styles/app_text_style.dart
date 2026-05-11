
import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';


class AppTextStyle{
    static TextStyle appName = TextStyle(
    fontSize: 35,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor,
  );

  static TextStyle HeadLine1 = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor,
  );

  static TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.blackColor,
  );

  static TextStyle subtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.blackColor,
  );

  static TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.blackColor,
  );

    static TextStyle displayTitle = TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryColor,
    );

    static TextStyle label = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.grayColor,
      letterSpacing: 0.8,
    );

    static TextStyle hint = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: AppColors.grayColor,
    );
}

