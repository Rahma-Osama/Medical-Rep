import 'package:flutter/material.dart';
import 'package:medical_rep/features/doctor_and_pharmacy/views/widgets/entity_card.dart';
import '../../../../core/styles/app_color.dart';
import '../../../../core/styles/app_text_style.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button_widget.dart';


class EntitiesListPage extends StatefulWidget {
  const EntitiesListPage({super.key});

  @override
  State<EntitiesListPage> createState() => _EntitiesListPageState();
}

class _EntitiesListPageState extends State<EntitiesListPage> {
  String selectedCategory = "All Doctors";

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          const CustomAppBar(label: "Doctor Management"),

          SliverToBoxAdapter(
            child: _buildHeaderSection(screenWidth, isWideScreen),
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isWideScreen ? screenWidth * 0.1 : screenWidth * 0.04,
              vertical: 10,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: EntityCard(),
                ),
                childCount: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(double screenWidth, bool isWideScreen) {
    return Container(
      color: AppColors.backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: isWideScreen ? screenWidth * 0.1 : screenWidth * 0.04,
              right: isWideScreen ? screenWidth * 0.1 : screenWidth * 0.04,
              bottom: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Manage your doctor contacts",
                    style: AppTextStyle.body.copyWith(
                      color: AppColors.grayColor,
                      fontSize: isWideScreen ? 14 : screenWidth * 0.032,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: isWideScreen ? 140 : 100,
                  height: 38,
                  child: CustomElevatedButton(
                    text: "Add",
                    icon: Icons.add,
                    borderRadius: 10,
                    onPressed: () {
                    },
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWideScreen ? screenWidth * 0.1 : screenWidth * 0.04,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search doctors...",
                  hintStyle: AppTextStyle.body.copyWith(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: AppColors.primaryColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tabs
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: isWideScreen ? screenWidth * 0.1 : screenWidth * 0.04,
              ),
              physics: const BouncingScrollPhysics(),
              children: [
                _categoryTab("All Doctors"),
                _categoryTab("Category A"),
                _categoryTab("Category B"),
                _categoryTab("Specialists"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryTab(String label) {
    bool isSelected = selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.lightgrayColor,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyle.body.copyWith(
              color: isSelected ? AppColors.whiteColor : AppColors.blackColor,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}