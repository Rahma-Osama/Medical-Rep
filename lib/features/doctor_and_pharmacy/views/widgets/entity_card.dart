import 'package:flutter/material.dart';
import '../../../../core/styles/app_color.dart';
import '../../../../core/styles/app_text_style.dart';
import '../doctor_profile_page.dart';

class EntityCard extends StatelessWidget {
  const EntityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    bool isWideScreen = screenWidth > 600;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      padding: EdgeInsets.all(isWideScreen ? 24 : screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(isWideScreen ? 16 : screenWidth * 0.04),
        border: Border.all(color: AppColors.grayColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: isWideScreen ? 30 : screenWidth * 0.065,
                    backgroundColor: AppColors.backgroundColor,
                    child: Text(
                      "DSJ",
                      style: AppTextStyle.body.copyWith(
                        color: AppColors.primaryColor,
                        fontSize: isWideScreen ? 16 : screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Dr. Sarah Johnson",
                        style: AppTextStyle.body.copyWith(
                          fontSize: isWideScreen ? 18 : screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Cardiology",
                        style: AppTextStyle.body.copyWith(
                          fontSize: isWideScreen ? 14 : screenWidth * 0.03,
                          color: AppColors.thirdColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildTag(screenWidth, "Category A", isWideScreen),
            ],
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
            child: Divider(height: 1, color: AppColors.lightgrayColor.withOpacity(0.5)),
          ),

          _buildInfoRow(screenWidth, Icons.phone_outlined, "+1 (555) 123-4567", isWideScreen),
          _buildInfoRow(screenWidth, Icons.email_outlined, "sarah.j@hospital.com", isWideScreen),
          _buildInfoRow(screenWidth, Icons.location_on_outlined, "City General Hospital, NY", isWideScreen),

          SizedBox(height: screenHeight * 0.015),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Last visit: 2/10/2026",
                style: AppTextStyle.body.copyWith(
                  fontSize: isWideScreen ? 14 : screenWidth * 0.028,
                  color: AppColors.grayColor,
                ),
              ),
              Text(
                "24 total visits",
                style: AppTextStyle.body.copyWith(
                  fontSize: isWideScreen ? 14 : screenWidth * 0.03,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.02),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const DoctorProfilePage()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isWideScreen ? 12 : screenWidth * 0.025),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: isWideScreen ? 18 : screenHeight * 0.015,
                    ),
                  ),
                  child: Text(
                    "View Full Details",
                    style: AppTextStyle.body.copyWith(
                      color: AppColors.whiteColor,
                      fontSize: isWideScreen ? 16 : screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(double screenWidth, IconData icon, String text, bool isWideScreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: isWideScreen ? 20 : screenWidth * 0.04, color: AppColors.thirdColor),
          const SizedBox(width: 10),
          Text(
            text,
            style: AppTextStyle.body.copyWith(
              fontSize: isWideScreen ? 14 : screenWidth * 0.032,
              color: AppColors.blackColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(double screenWidth, String label, bool isWideScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWideScreen ? 12 : screenWidth * 0.025, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyle.body.copyWith(
          color: AppColors.secondaryColor,
          fontSize: isWideScreen ? 12 : screenWidth * 0.028,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}