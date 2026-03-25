import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key, required this.label});
  final  String label;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.backgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 16),
              title:  Text(label,
                style: AppTextStyle.title.copyWith(
                  color: AppColors.whiteColor
                )
                ),

              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [AppColors.primaryColor, AppColors.thirdColor],
                  ),
                ),

                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: CircleAvatar(radius: 80, backgroundColor: AppColors.whiteColor.withOpacity(0.05)),
                    ),
                  ],

                ),

              ),

            ),

          );
  }
}