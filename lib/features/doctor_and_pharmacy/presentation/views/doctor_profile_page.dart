import 'package:flutter/material.dart';
import '../../../../../core/styles/app_color.dart';
import '../../../../../core/styles/app_text_style.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/entities/medical_entity.dart';

class DoctorProfilePage extends StatelessWidget {
  final MedicalEntity doctor;

  const DoctorProfilePage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // الـ App Bar المميز بتاعنا
          const CustomAppBar(label: "Doctor Profile"),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                children: [
                  // كارت بيانات الدكتور الأساسية (Header)
                  _buildProfileHeader(doctor),

                  const SizedBox(height: 25),

                  // قسم المعلومات الشخصية والمكان
                  _buildSectionTitle("Contact & Location"),
                  const SizedBox(height: 10),
                  _infoCard([
                    _infoItem("Email Address", doctor.email, Icons.email_outlined),
                    _infoItem("Full Address", doctor.address, Icons.location_on_outlined),
                  ]),

                  const SizedBox(height: 25),

                  // قسم البيانات المهنية
                  _buildSectionTitle("Professional Details"),
                  const SizedBox(height: 10),
                  _infoCard([
                    _infoItem("Category", doctor.category, Icons.category_outlined),
                    _infoItem("Affiliated Hospital", doctor.hospital, Icons.local_hospital_outlined),
                    _infoItem("Specialization", doctor.specialty, Icons.medical_services_outlined),
                  ]),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // الـ Header اللي فيه الصورة والاسم والتخصص
  Widget _buildProfileHeader(MedicalEntity doc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
            child: Text(
              doc.name.isNotEmpty ? doc.name[0].toUpperCase() : "?",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            doc.name,
            textAlign: TextAlign.center,
            style: AppTextStyle.title.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              doc.specialty,
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // حاوية مجمعة للمعلومات عشان تدي شكل نظيف
  Widget _infoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Column(children: children),
    );
  }

  // سطر المعلومات الفردي
  Widget _infoItem(String title, String value, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: AppColors.grayColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        value,
        style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    );
  }

  // عنوان الأقسام
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppTextStyle.body.copyWith(
          color: AppColors.grayColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}