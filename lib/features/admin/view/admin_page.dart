import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/core/widgets/custom_app_bar.dart';
import 'package:medical_rep/features/Auth/views/LoginView.dart';
import 'package:medical_rep/features/admin/cubit/admin_state.dart';
import 'package:medical_rep/features/admin/data/data%20source/admin_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../cubit/admin_cubit.dart';
import 'representative_plan_details.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminCubit>(
      create: (context) =>
          AdminCubit(AdminRemoteDataSource())..fetchAllRepresentativesPlans(),
      child: const AdminPanelBody(),
    );
  }
}

class AdminPanelBody extends StatelessWidget {
  const AdminPanelBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          CustomAppBar(
            label: 'Manager Dashboard',
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),

          // ✅ التحكم بالكامل عبر الـ BlocBuilder داخل الـ Sliver
          BlocBuilder<AdminCubit, AdminState>(
            builder: (context, state) {
              // 1️⃣ حالة التحميل: اللودر يظهر هنا فقط ويختفي تماماً بعدها
              if (state is AdminLoading) {
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors
                          .primaryColor, // أو اللون البنفسجي الأساسي عندك
                    ),
                  ),
                );
              }

              // 2️⃣ حالة الخطأ
              if (state is AdminError) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Center(
                      child: Text(
                        "Error: ${state.errorMessage}",
                        style: AppTextStyle.body.copyWith(color: Colors.red),
                      ),
                    ),
                  ),
                );
              }

              // 3️⃣ حالة النجاح وعرض الكروت (بدون أي لودر إضافي)
              if (state is AdminSuccess) {
                final userIds = state.userIds;
                final groupedPlans = state.groupedPlans;

                if (userIds.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Center(
                        child: Text(
                          "No plans submitted yet.",
                          style: AppTextStyle.body
                              .copyWith(color: AppColors.grayColor),
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(
                        "Representatives Plans",
                        style: AppTextStyle.title
                            .copyWith(color: AppColors.grayColor, fontSize: 18),
                      ),
                      const SizedBox(height: 15),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: userIds.length,
                        itemBuilder: (context, index) {
                          String userId = userIds[index];
                          List<Map<String, dynamic>> visits =
                              groupedPlans[userId]!;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: AppColors.grayColor.withOpacity(0.2)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.person,
                                    color: AppColors.primaryColor),
                              ),
                              title: Text(
                                "Rep ID: ${userId.length > 8 ? userId.substring(0, 8).toUpperCase() : userId}",
                                style:
                                    AppTextStyle.title.copyWith(fontSize: 16),
                              ),
                              subtitle: Text(
                                "Total Visits: ${visits.length}",
                                style: AppTextStyle.body
                                    .copyWith(color: AppColors.grayColor),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios,
                                  size: 16, color: AppColors.primaryColor),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RepresentativePlanDetails(
                                      userId: userId,
                                      onRefresh: () {
                                        if (context.mounted) {
                                          context
                                              .read<AdminCubit>()
                                              .fetchAllRepresentativesPlans();
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ]),
                  ),
                );
              }

              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
        ],
      ),
    );
  }
}
