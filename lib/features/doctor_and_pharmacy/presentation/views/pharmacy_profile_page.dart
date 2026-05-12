import 'package:flutter/material.dart';
import '../../../../../core/styles/app_color.dart';
import '../../../../../core/styles/app_text_style.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_button_widget.dart';
import '../../domain/entities/medical_entity.dart';

class PharmacyProfilePage extends StatefulWidget {
  final MedicalEntity pharmacy; // استقبال بيانات الصيدلية

  const PharmacyProfilePage({super.key, required this.pharmacy});

  @override
  State<PharmacyProfilePage> createState() => _PharmacyProfilePageState();
}

class _PharmacyProfilePageState extends State<PharmacyProfilePage> {
  // البيانات دي المفروض تيجي من الـ Cubit بس هنخليها هنا مؤقتاً للتوضيح
  late List<Map<String, dynamic>> relatedDoctors;

  @override
  void initState() {
    super.initState();
    relatedDoctors = [
      {"name": "Dr. Sarah Johnson", "specialty": "Cardiology", "isWriting": true},
      {"name": "Dr. Ahmed Meyer", "specialty": "Internal Medicine", "isWriting": false},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const CustomAppBar(label: "Pharmacy Profile"),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWideScreen ? screenWidth * 0.1 : screenWidth * 0.04,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPharmacyHeader(widget.pharmacy),
                  const SizedBox(height: 25),

                  _buildSectionTitle("Doctors Prescription Tracking"),
                  _buildDoctorsTrackingList(),
                  const SizedBox(height: 25),

                  _buildSectionTitle("Inventory Status"),
                  _buildInventoryCard(),
                  const SizedBox(height: 25),

                  _buildSectionTitle("Feedback"),
                  _buildNotesSection(),

                  const SizedBox(height: 30),
                  CustomElevatedButton(
                    text: "Save Visit Report",
                    onPressed: () {
                      // Logic للحفظ عبر الـ Cubit
                    },
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyHeader(MedicalEntity pharmacy) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.local_pharmacy_rounded, color: AppColors.primaryColor, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pharmacy.name, style: AppTextStyle.title.copyWith(fontSize: 18)),
                Text(pharmacy.address, style: AppTextStyle.body.copyWith(fontSize: 12, color: AppColors.grayColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsTrackingList() {
    return Container(
      decoration: BoxDecoration(color: AppColors.whiteColor, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: List.generate(relatedDoctors.length, (index) {
          final doc = relatedDoctors[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.backgroundColor,
              child: Icon(Icons.person, color: AppColors.primaryColor, size: 20),
            ),
            title: Text(doc['name'], style: AppTextStyle.body.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(doc['specialty'], style: AppTextStyle.body.copyWith(fontSize: 12, color: AppColors.grayColor)),
            trailing: Switch(
              value: doc['isWriting'],
              onChanged: (val) => setState(() => relatedDoctors[index]['isWriting'] = val),
              activeColor: Colors.green,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInventoryCard() {
    return Container(
      decoration: BoxDecoration(color: AppColors.whiteColor, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _inventoryRow("Panadol Extra", "Available", Colors.green),
          const Divider(height: 1, indent: 15, endIndent: 15),
          _inventoryRow("C-Retard", "Out of Stock", Colors.red),
        ],
      ),
    );
  }

  Widget _inventoryRow(String name, String status, Color color) {
    return ListTile(
      title: Text(name, style: AppTextStyle.body.copyWith(fontSize: 14)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      decoration: BoxDecoration(color: AppColors.whiteColor, borderRadius: BorderRadius.circular(15)),
      child: TextField(
        maxLines: 3,
        decoration: InputDecoration(
          hintText: "Add notes about today's visit...",
          hintStyle: AppTextStyle.body.copyWith(color: Colors.grey, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title, style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }
}