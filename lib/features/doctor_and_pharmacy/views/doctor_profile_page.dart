import 'package:flutter/material.dart';
import '../../../../core/styles/app_color.dart';
import '../../../../core/styles/app_text_style.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button_widget.dart';

class DoctorProfilePage extends StatelessWidget {
  const DoctorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          const CustomAppBar(label: "Doctor Details"),


          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWideScreen ? screenWidth * 0.1 : screenWidth * 0.04,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(screenWidth, isWideScreen),
                  const SizedBox(height: 25),

                  _buildSectionTitle(screenWidth, isWideScreen, "Contact Information"),
                  _buildDetailItem(screenWidth, isWideScreen, Icons.phone_android_rounded, "Phone Number", "+1 (555) 123-4567"),
                  _buildDetailItem(screenWidth, isWideScreen, Icons.location_on_rounded, "Clinic Address", "123 Medical Center Dr, NY"),
                  _buildDetailItem(screenWidth, isWideScreen, Icons.calendar_today_rounded, "Working Days", "Mon - Fri, 02:00 PM - 08:00 PM"),

                  const SizedBox(height: 25),

                  _buildSectionTitle(screenWidth, isWideScreen, "Recent Visits History"),
                  _buildHistoryItem(isWideScreen, "Mar 10, 2026", "Requested Product X samples, very interested in the new clinical trials."),
                  _buildHistoryItem(isWideScreen, "Feb 22, 2026", "Follow up visit, discussed new pricing and pharmacy availability."),

                  const SizedBox(height: 30),


                  // CustomElevatedButton(
                  //   text: "Start New Visit",
                  //   onPressed: () {
                  //   },
                  // ),
                  //
                  // const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double screenWidth, bool isWideScreen) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isWideScreen ? 40 : 35,
            backgroundColor: AppColors.backgroundColor,
            child: Icon(Icons.person_rounded, size: isWideScreen ? 45 : 40, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dr. Sarah Johnson", style: AppTextStyle.title.copyWith(fontSize: 18)),
                const SizedBox(height: 4),
                Text("Cardiology Specialist",
                    style: AppTextStyle.body.copyWith(color: AppColors.grayColor, fontSize: 13)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text("Category A",
                      style: TextStyle(color: AppColors.primaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(double screenWidth, bool isWideScreen, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 4),
      child: Text(title,
          style: AppTextStyle.subtitle.copyWith(
              color: AppColors.blackColor,
              fontWeight: FontWeight.bold,
              fontSize: 16)),
    );
  }

  Widget _buildDetailItem(double screenWidth, bool isWideScreen, IconData icon, String title, String val) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyle.body.copyWith(fontSize: 11, color: AppColors.grayColor)),
                Text(val, style: AppTextStyle.body.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(bool isWideScreen, String date, String note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: AppTextStyle.body.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
              const Icon(Icons.check_circle, size: 18, color: Colors.green),
            ],
          ),
          const SizedBox(height: 8),
          Text(note, style: AppTextStyle.body.copyWith(color: AppColors.grayColor, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}