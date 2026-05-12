import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/styles/app_color.dart';
import '../../../../../core/styles/app_text_style.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../cubit/medical_cubit.dart';
import '../cubit/medical_state.dart';
import '../widgets/entity_card.dart';

class EntitiesListPage extends StatefulWidget {
  const EntitiesListPage({super.key});

  @override
  State<EntitiesListPage> createState() => _EntitiesListPageState();
}

class _EntitiesListPageState extends State<EntitiesListPage> {
  @override
  void initState() {
    super.initState();
    // استدعاء البيانات من السيرفر فور فتح الصفحة
    context.read<MedicalCubit>().fetchEntities();
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
          // رجعنا العنوان الأساسي اللي عجبك
          const CustomAppBar(label: "Doctor Management"),

          // الهيدر المعدل (سطر واحد شيك)
          SliverToBoxAdapter(
            child: _buildHeaderSection(screenWidth, isWideScreen),
          ),

          // عرض القائمة بناءً على حالة الـ Cubit
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isWideScreen ? screenWidth * 0.1 : screenWidth * 0.04,
              vertical: 10,
            ),
            sliver: BlocBuilder<MedicalCubit, MedicalState>(
              builder: (context, state) {
                if (state is MedicalLoading) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                else if (state is MedicalSuccess) {
                  if (state.entities.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: Text(
                            "No records found.",
                            style: AppTextStyle.body.copyWith(color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  }

                  // عرض الـ 500 دكتور
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: EntityCard(entity: state.entities[index]),
                      ),
                      childCount: state.entities.length,
                    ),
                  );
                }

                else if (state is MedicalError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Text("Connection issues", style: const TextStyle(color: Colors.red)),
                      ),
                    ),
                  );
                }

                return const SliverToBoxAdapter(child: SizedBox());
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  // الهيدر "السطر الواحد" اللي بيعبر عن الصفحة
  Widget _buildHeaderSection(double screenWidth, bool isWideScreen) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: isWideScreen ? screenWidth * 0.1 : screenWidth * 0.06,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Registered Medical Professionals", // سطر واحد رسمي وشيك
            style: AppTextStyle.body.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.grayColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}


